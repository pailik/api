<?php

namespace Kubikvest\Mapper;

use Packaged\QueryBuilder\Assembler\QueryAssembler;
use Kubikvest\Model;

/**
 * Class User
 * @package Kubikvest\Mapper
 */
class User
{
    /**
     * @var
     */
    protected $pdo;

    /**
     * @var
     */
    protected $queryBuilder;

    /**
     * @param $pdo
     * @param $queryBuilder
     */
    public function __construct($pdo, $queryBuilder)
    {
        $this->pdo = $pdo;
        $this->queryBuilder = $queryBuilder;
    }

    /**
     * @param int $userId
     *
     * @return Model\User
     */
    public function getUser($userId)
    {
        $user = new Model\User();
        try {
            $query = $this->queryBuilder
                ->select(
                    'userId',
                    'accessToken',
                    'kvestId',
                    'pointId',
                    'startTask'
                )
                ->from('user')
                ->where(['userId' => $userId]);
            $record = $this->pdo->query(QueryAssembler::stringify($query))
                ->fetch(\PDO::FETCH_ASSOC);
            if (!empty($record)) {
                $user->userId      = (int) $record['userId'];
                $user->accessToken = $record['accessToken'];
                $user->kvestId     = (int) $record['kvestId'];
                $user->pointId     = (int) $record['pointId'];
                $user->startTask   = $record['startTask'];
            }
        } catch(\Exception $e) {
            //
        }

        return $user;
    }

    /**
     * @param string $accessToken
     *
     * @return Model\User
     */
    public function getIdByToken($accessToken)
    {
        $user = new Model\User();
        try {
            $query = $this->queryBuilder
                ->select('userId')
                ->from('user')
                ->where(['accessToken' => $accessToken]);
            $record = $this->pdo->exec(QueryAssembler::stringify($query))
                ->fetch();
            if (!empty($record)) {
                $user->userId = $record['userId'];
                $user->accessToken = $record['accessToken'];
            }
        } catch(\Exception $e) {
            //
        }

        return $user;
    }

    /**
     * @param Model\User $user
     *
     * @return Model\User
     */
    public function newbie(Model\User $user)
    {
        $query = $this->queryBuilder
            ->insertInto('user', 'userId', 'accessToken', 'kvestId', 'pointId')
            ->values(
                $user->userId,
                $user->accessToken,
                $user->kvestId,
                $user->pointId
            );
        $this->pdo->exec(QueryAssembler::stringify($query));

        return $user;
    }

    /**
     * @param Model\User $user
     */
    public function update(Model\User $user)
    {
        $query = $this->queryBuilder
            ->update('user', [
                'accessToken' => $user->accessToken,
                'kvestId'     => $user->kvestId,
                'pointId'     => $user->pointId,
            ])
            ->where(['userId' => $user->userId]);
        $this->pdo->exec(QueryAssembler::stringify($query));
    }

    /**
     * @param Model\User $user
     */
    public function setStartTask(Model\User $user)
    {
        $query = $this->queryBuilder
            ->update('user', [
                'startTask' => $user->startTask,
            ])
            ->where(['userId' => $user->userId]);
        $this->pdo->exec(QueryAssembler::stringify($query));
    }
}
