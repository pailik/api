<?php

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;

$app->post('/device', function (Request $request) use ($app) {
    $jsonResponse = new JsonResponse();
    $jsonResponse->setStatusCode(200);
    $data   = json_decode($request->getContent(), true);

    $request = [
        'deviceId' => $data['deviceId'],
        'platform' => $data['platform'],
        'locale'   => $data['locale'],
    ];

    $token = $app['security']->getToken();

    if ($token instanceof \Silex\Component\Security\Http\Token\JWTToken) {
        $request['siteId'] = $token->getUser();
    }

    $app['service.push']->cast('saveDevice', [$request]);

    $app['logger']->log(LogLevel::INFO, 'registered new device');

    return $jsonResponse;
});
