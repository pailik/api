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

    /**
     * @var \Kubikvest\Model\User $user
     */
    $user = $app['user.mapper']->getUser($data['user_id']);

    if ($user->isEmpty()) {
        $user->userId = $data['user_id'];
        $user->accessToken = $data['access_token'];
        $user->kvestId = 1;
        $user->pointId = 0;
        $app['user.mapper']->newbie($user);
    } else {
        $user->accessToken = $data['access_token'];
        $app['user.mapper']->update($user);
    }

    return new JsonResponse(
        [
            'links' => [
                'task' => $app['url'] . '/task?t=' . JWT::encode(
                        [
                            'auth_provider' => 'vk',
                            'user_id'       => $user->userId,
                            'ttl'           => $data['expires_in'],
                            'kvest_id'      => $user->kvestId,
                            'point_id'      => $user->pointId,
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
        $data = JWT::decode($jwt, $app['key'], ['HS256']);
    } catch(Exception $e) {
        return new JsonResponse(
            [
                'error' => $e->getMessage(),
            ],
            JsonResponse::HTTP_BAD_REQUEST
        );
    }

    /**
     * @var \Kubikvest\Model\User $user
     */
    $user = $app['user.mapper']->getUser($data->user_id);

    $response = [
        'description'  => $app['tasks'][$user->kvestId][$user->pointId]['description'],
        'point_id'     => $user->pointId,
        'total_points' => count($app['tasks'][$user->kvestId]),
        'links' => [
            'checkpoint' => $app['url'] . '/checkpoint?t=' . JWT::encode(
                    [
                        'auth_provider' => 'vk',
                        'user_id'       => $user->userId,
                        'ttl'           => $data->ttl,
                        'kvest_id'      => $user->kvestId,
                        'point_id'      => $user->pointId,
                    ],
                    $app['key']
                )
        ],
    ];

    if (null === $user->startTask) {
        $user->startTask = date('Y-m-d h:i:s');
        $app['user.mapper']->setStartTask($user);
    }

    $response['start_task'] = $user->startTask;

    $startTask  = new DateTime($user->startTask);
    $sinceStart = $startTask->diff(new DateTime());

    foreach ($app['tasks'][$user->kvestId][$user->pointId]['prompt'] as $k => $v) {
        if ($k > $sinceStart->i) {
            $response['timer'] = $k - $sinceStart->i;
            break;
        }
    }

    foreach ($app['tasks'][$user->kvestId][$user->pointId]['prompt'] as $k => $v) {
        if ($sinceStart->i >= $k) {
            $response['prompt'] = $v;
        }
    }

    return new JsonResponse($response, JsonResponse::HTTP_OK);
});

$app->get('/checkpoint', function (Request $request) use ($app) {
    $jwt    = $request->get('t');
    $coords = $request->get('c');
    list($lat, $lon) = explode(',', $coords);

    try {
        $data = JWT::decode($jwt, $app['key'], ['HS256']);
    } catch(Exception $e) {
        return new JsonResponse(
            [
                'error' => $e->getMessage(),
            ],
            JsonResponse::HTTP_BAD_REQUEST
        );
    }

    /**
     * @var \Kubikvest\Model\User $user
     */
    $user = $app['user.mapper']->getUser($data->user_id);

    $response['total_points'] = count($app['tasks'][$user->kvestId]);
    $response['finish']       = false;
    /**
     * @var Closure $checkCoordinates
     */
    $checkCoordinates = $app['checkCoordinates'];
    if (!$checkCoordinates($user->kvestId, $user->pointId, (int) $lat, (int) $lon)) {
        $response['links']['checkpoint'] = $app['url'] . '/checkpoint?t=' . JWT::encode(
            [
                'auth_provider' => 'vk',
                'user_id'       => $user->userId,
                'ttl'           => $data->ttl,
                'kvest_id'      => $user->kvestId,
                'point_id'      => $user->pointId,
            ],
            $app['key']
        );
        $response['error'] = 'Не верное место отметки.';
    } else {
        $user->pointId++;
        $user->startTask = null;
        $app['user.mapper']->update($user);
    }

    $response['description'] = $app['tasks'][$user->kvestId][$user->pointId]['description'];
    if ($user->pointId == count($app['tasks'][$user->kvestId])) {
        $response['links']['finish'] = $app['url'] . '/finish?t=' . JWT::encode(
            [
                'auth_provider' => 'vk',
                'user_id'       => $user->userId,
                'ttl'           => $data->ttl,
                'kvest_id'      => $user->kvestId,
                'point_id'      => $user->pointId,
            ],
            $app['key']
        );
        $user->pointId = 0;
        $app['user.mapper']->update($user);
        $response['finish'] = true;
    } else {
        $response['links']['task'] = $app['url'] . '/task?t=' . JWT::encode(
            [
                'auth_provider' => 'vk',
                'user_id'       => $user->userId,
                'ttl'           => $data->ttl,
                'kvest_id'      => $user->kvestId,
                'point_id'      => $user->pointId,
            ],
            $app['key']
        );
    }

    return new JsonResponse($response, JsonResponse::HTTP_OK);
});

$app->get('/finish', function (Request $request) use ($app) {
    $jwt = $request->get('t');

    try {
        $data = JWT::decode($jwt, $app['key'], ['HS256']);
    } catch(Exception $e) {
        return new JsonResponse(
            [
                'error' => $e->getMessage(),
            ],
            JsonResponse::HTTP_BAD_REQUEST
        );
    }

    /**
     * @var \Kubikvest\Model\User $user
     */
    $user = $app['user.mapper']->getUser($data->user_id);

    return new JsonResponse(
        [
            'description'  => $app['tasks'][$user->kvestId][$user->pointId]['description'],
            'point_id'     => $user->pointId,
            'total_points' => count($app['tasks'][$user->kvestId]),
            'links' => [
                'checkpoint' => $app['url'] . '/checkpoint?t=' . JWT::encode(
                        [
                            'auth_provider' => 'vk',
                            'user_id'       => $user->userId,
                            'ttl'           => $data->ttl,
                            'kvest_id'      => $user->kvestId,
                            'point_id'      => $user->pointId,
                        ],
                        $app['key']
                    )
            ],
        ],
        JsonResponse::HTTP_OK
    );
});

$app->run();
