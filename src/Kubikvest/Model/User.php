<?php

namespace Kubikvest\Model;

class User extends \ActiveRecord\Model
{
    public function getIdByToken($accessToken)
    {
        $user = self::find(['accessToken' => $accessToken]);
        return $user->userId;
    }
}
