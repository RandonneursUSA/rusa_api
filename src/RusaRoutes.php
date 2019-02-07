<?php

/**
 * @file
 *  RusaRoutes.php
 *
 * @Creted 
 *  2018-01-09 - Paul Lieberman
 *
 * Gets and holds Route data for given Region
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets and holds routes data
 *
 */
class RusaRoutes {

  protected $routes;

  public function __construct($params = []) {
    $query = ['dbname' => 'routes'];
    if (!empty($params['key']) && !empty($params['val'])) {
      $query += $params;
    }

    // Get routes for region from GDBM
    $client    = new RusaClient();
    $db_routes =  $client->get($query);

    foreach ($db_routes as $route) {
      $this->routes[$route->rtid] = $route;
    }  

  }

  /**
   * Get all Routes
   *
   */
  public function getRoutes(){
    return $this->routes;
  }

  /**
   * Get active Routes
   *
   */
  public function getActiveRoutes(){
    $routes = [];
    foreach ($this->routes as $rtid => $route) {
      if ($route->active == '1') {
        $routes[$rtid] = $route;
      }
    }
    return $routes;

  }

  /**
   * Get single Route by id
   *
   */
  public function getRoute($rtid){
    return $this->routes[$rtid];
  }

  /** Get Routes by distance 
   *  Only routes between distance and +20% of distance
   */
  public function getRoutesByDistance($dist){
    $results = [];
    foreach ($this->routes as $rtid => $route) {
      if ($route->dist >= $dist && $route->dist <= $dist * 1.2 && $route->active == '1') {
        $results[$rtid] = $route;
      }
    }
    return $results;
  }

  /**
   * Get single Route distance
   *
   */
  public function getRouteDistance($rtid){
    return $this->routes[$rtid]->dist;
  }

  /**
   * Get route line
   *
   * Combines distance, route name, and start into a string
   *
   */
  public function getRouteLine($rtid) {
    $route = $this->routes[$rtid];

    $route_name = empty($route->name) ? "Unnamed route" : $route->name;
    $route_line = "Route: " .  $rtid .  " (" . $route->dist . "km) " .  "\"" . $route_name . "\"  " .  $route->start;
   
    return $route_line;
  }

  /**
   * Get routes sorted by distance and id
   *
   */
  public function getRoutesSorted() {
    $routes = $this->routes;

    // Sort by distance and then route id
    foreach ($routes as $key => $route) {
      $asort[$key] = $route->dist;
      $bsort[$key] = $route->rtid;;
    }

    array_multisort($asort, SORT_NUMERIC, SORT_ASC,
                    $bsort, SORT_NUMERIC, SORT_ASC,
                    $routes);
    return $routes;
  }

} // End of class
