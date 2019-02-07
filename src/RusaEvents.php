<?php

/**
 * @file
 *  RusaEvents.php
 *
 * @Creted
 *  2018-01-09 - Paul Lieberman
 *
 * RBA Self Service Form
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets and holds events data for given region
 *
 */
class RusaEvents {

  protected $events;

  public function __construct($params = []) {
    $region_id = isset($params['regid']) ? $params['regid'] : '10'; // Defaults to Boulder CO
//    $year = isset($params['year']) ? $params['year'] : date('Y');


    // Get events for region from GDBM
    $this->events = $this->read_db_events($region_id);
  }

  /**
   * Get all events
   *
   */
  public function getEvents(){
    return $this->events;
  }

  /**
   * Get single event by id
   *
   */
  public function getEvent($eid) {
    return $this->events[$eid];
  }

  /**
   * Assign route
   *
   */
  public function setRoute($eid, $rtid) {
    if (!empty($rtid)) {
      $this->events[$eid]->rtid = $rtid;
    }
  }

  /**
   * Get distance
   *
   */
  public function getEventDistance($eid) {
    return $this->events[$eid]->dist;
  }

  /**
   * Assign distance
   *
   */
  public function setDistance($eid, $dist) {
    if (!empty($dist)) {
      $this->events[$eid]->dist = $dist;
    }
  }

  /**
   *
   */
  private function read_db_events($regid) {
    $client = new RusaClient();

    $query = [
      'dbname' => 'events',
      'key'    => 'regid',
      'val'    => $regid,
    ];

    // Get the events
    $db_events = $client->get($query);

    // Get the results status
    $query = [
      'dbname' => 'rstatus',
      'key'    => 'rsid',
    ];

    $events = [];

    foreach ($db_events as $db_event) {
      // Get all events from 30 days ago on
      if ($db_event->date >= date('Y/m/d', strtotime('-30 days'))) {
        $event = new \stdClass();
        $event->type             = $db_event->type;
        $event->dist             = $db_event->dist;
        $event->date             = $db_event->date;
        $event->rtid             = $db_event->rtid;

        // If event is in the past
        if (date("Y/m/d") >= $event->date) {
          // Check rstatus
          $query['val'] = $db_event->eid;
          $rstatus = $client->get($query);
          $event->resultsSubmitted = ! empty($rstatus);
        }
        $events[$db_event->eid] = $event;
      }
    }
    return $events;
  } // EoF

} // EoC

