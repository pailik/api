<?php

namespace Kubikvest\Model;

class User
{
    public $userId = null;
    public $accessToken = null;
    public $kvestId = null;
    public $pointId = null;

    /**
     * @return bool
     */
    public function isEmpty()
    {
        return null === $this->userId;
    }

    public static function getFields()
    {
        return [
            'userId',
            'accessToken',
            'kvestId',
            'pointId',
        ];
    }
}
