<?php

use Silex\Application;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Firebase\JWT\JWT;
use Kubikvest\Model;

require_once __DIR__ . '/../vendor/autoload.php';

$config = require_once __DIR__ . '/../config/app.php';
$app    = new Application($config);

$app->get('/auth', function(Request $request) use ($app) {
    $code = $request->get('code');

    try {
        $response = $app['curl']->request('GET', '/access_token', [
            'query' => [
                'client_id'     => $app['client_id'],
                'client_secret' => $app['client_secret'],
                'redirect_uri'  => $app['redirect_uri'],
                'code'          => $code,
            ]
        ]);
    } catch (RuntimeException $e) {
        return new JsonResponse(
            [
                'error' => $e->getMessage(),
            ],
            JsonResponse::HTTP_INTERNAL_SERVER_ERROR
        );
    }

    $data = json_decode($response->getBody()->__toString(), true);

    $user = new Model\User();
    $user->userId = $data['user_id'];
    $user->accessToken = $data['access_token'];
    $app['user.mapper']->save($user);

    return new JsonResponse(
        [
            'links' => [
                'task' => $app['url'] . '/task?t=' . JWT::encode(
                        [
                            'auth_provider' => 'vk',
                            'user_id'       => $data['user_id'],
                            'ttl'           => $data['expires_in'],
                            'kvest_id'      => 1,
                            'point_id'      => 0,
                        ],
                        $app['key']
                    ),
            ]
        ],
        JsonResponse::HTTP_OK
    );
});

$app->get('/task', function (Request $request) use ($app) {
    $jwt = $request->get('t');

    try {
        $decoded = JWT::decode($jwt, $app['key'], ['HS256']);
    } catch(Exception $e) {
        return new JsonResponse(
            [
                'error' => $e->getMessage(),
            ],
            JsonResponse::HTTP_BAD_REQUEST
        );
    }

    $user   = new Model\User();
    $userId = $user->getIdByToken($decoded['user_id']);

    return new JsonResponse(
        [
            'description'  => $app['tasks']['kvest_id']['point_id']['description'],
            'point_id'     => $decoded['point_id'],
            'total_points' => count($app['tasks']['kvest_id']),
            'links' => [
                'checkpoint' => $app['host'] . '/checkpoint?t=' . JWT::encode(
                        [
                            'auth_provider' => 'vk',
                            'user_id'       => $userId,
                            'kvest_id'      => $decoded['kvest_id'],
                            'point_id'      => $decoded['point_id'],
                        ],
                        $app['key']
                    )
            ],
        ],
        JsonResponse::HTTP_OK
    );
});

$app->get('/checkpoint', function (Request $request) use ($app) {
    $jwt    = $request->get('t');
    $coords = $request->get('c');

    try {
        $decoded = JWT::decode($jwt, $app['key'], ['HS256']);
    } catch(Exception $e) {
        return new JsonResponse(
            [
                'error' => $e->getMessage(),
            ],
            JsonResponse::HTTP_BAD_REQUEST
        );
    }

    return new JsonResponse(
        [
            'description'  => $app['tasks']['kvest_id']['point_id']['description'],
            'point_id'     => $decoded['point_id'],
            'total_points' => count($app['tasks']['kvest_id']),
            'links' => [
                'nextpoint' => $app['host'] . '/checkpoint?t=' . JWT::encode(
                    [
                        'auth_provider' => 'vk',
                        'client_id'     => $decoded['client_id'],
                        'kvest_id'      => $decoded['kvest_id'],
                        'point_id'      => $decoded['point_id'],
                    ],
                    $app['key']
                )
            ],
        ],
        JsonResponse::HTTP_OK
    );
});

$app->run();
