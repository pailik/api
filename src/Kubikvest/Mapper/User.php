<?php

namespace Kubikvest\Mapper;

use Packaged\QueryBuilder\Assembler\QueryAssembler;

class User
{
    protected $pdo;
    protected $queryBuilder;

    public function __construct($pdo, $queryBuilder)
    {
        $this->pdo = $pdo;
        $this->queryBuilder = $queryBuilder;
    }

    /**
     * @param string $accessToken
     *
     * @return \Kubikvest\Model\User
     */
    public function getIdByToken($accessToken)
    {
        $user = new \Kubikvest\Model\User();
        try {
            $query = $this->queryBuilder->select('userId')->from('user')->where(['accessToken' => $accessToken]);
            $record = $this->pdo->exec(QueryAssembler::stringify($query))->fetch();
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
     * @param \Kubikvest\Model\User $user
     *
     * @return \Kubikvest\Model\User
     */
    public function save(\Kubikvest\Model\User $user)
    {
        $query = $this->queryBuilder
            ->insertInto('user', 'userId', 'accessToken')
            ->values($user->userId, $user->accessToken);
        $this->pdo->exec(QueryAssembler::stringify($query));

        return $user;
    }
}
