<?php

use Silex\Application;
use GuzzleHttp\Client as GuzzleClient;

return [
    'client_id' => '',
    'client_secret' => '',
    'redirect_uri' => 'kubikvest.xyz',
    'curl' => function () {
        return new GuzzleClient([
            'base_uri' => 'https://oauth.vk.com',
            'headers'  => ['content-type' => 'text/xml; charset=utf-8'],
            'http_errors' => false,
            'debug' => false,
        ]);
    },
    'tasks' => [
        1 => [
            [
                'kvest'       => 1,
                'point'       => 0,
                'description' => 'Вы должны прийти сюда чтобы начать',
                'coords' => [
                    'latitude'  => [10, 20],
                    'longitude' => [30, 40],
                ],
            ],
            [
                'kvest'       => 1,
                'point'       => 1,
                'description' => 'description description 11',
                'coords' => [
                    'latitude'  => [10, 20],
                    'longitude' => [30, 40],
                ],
            ],
        ],
    ],
];
