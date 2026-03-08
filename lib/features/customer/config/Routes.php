<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->group('api/v1/customer', [
    'namespace' => 'App\Modules\Customer\Controllers',
    'filter'    => 'auth',
], function ($routes) {
    $routes->get('categories', 'CustomerController::getCategories');
    $routes->get('categories/(:num)/services', 'CustomerController::getServicesByCategory/$1');
    $routes->get('services/(:num)', 'CustomerController::getServiceDetails/$1');
});