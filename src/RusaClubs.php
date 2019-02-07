<?php

/**
 * @file
 *  RusaClubs.php
 *
 * @Creted 
 *  2018-01-09 - Paul Lieberman
 *
 * RusaClubs
 *
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets and holds clubs data
 *
 */
class RusaClubs {

  protected $clubs;

  public function __construct($params = []) {
    $client  = new RusaClient();
    $query   = ['dbname' => 'clubs'];

    // If we are passed a key/value
    if (!empty($params['key']) && !empty($params['val'])) {
     $query += $params;
    }
    // Get the data
    $data = $client->get($query);

    // Store keyed on acpcode
    foreach ($data as $club) {
      $this->clubs[$club->acpcode] = $club;
    }

    // Sort by acpcode
    ksort($this->clubs);
  }

  /**
   * Get all the clubs
   *
   */
  public function getClubs(){
    return $this->clubs;
  }

  /**
   * Get a single club
   *
   */
  public function getClub($acpcode = '') {
    if (!empty($acpcode)) {
      return $this->clubs[$acpcode];
    }
    else {
      // If no acpcode return the name of the first or only club
      return $this->clubs[array_keys($this->clubs)[0]];
    }
  }

  /**
   * Get a club name
   *
   */
  public function getClubName($acpcode = '') {
    if (!empty($acpcode)) {
      return $this->clubs[$acpcode]->name;
    }
    else {
      // If no acpcode return the name of the first or only club
      return $this->clubs[array_keys($this->clubs)[0]]->name;
    }
  }

  /**
   * Get and array for a  select list of clubs
   *
   */
  public function getClubsSelect() {
    $options = [];
    foreach ($this->clubs as $acpcode => $club) {
      $options[$acpcode] = $club->name . " " . $acpcode;
    }
    return $options;
  }


} // End of class

