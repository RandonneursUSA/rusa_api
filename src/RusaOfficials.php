<?php

/**
 * @file
 *  RusaOfficials.php
 *
 * @Creted 
 *  2018-01-09 - Paul Lieberman
 *
 * RBA Officials
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets and holds routes data
 *
 */
class RusaOfficials {

  protected $client;
  protected $officials;
  protected $titles;

  public function __construct($params = []) {
    $query = ['dbname' => 'officials'];

    if (!empty($params['key']) && !empty($params['val'])) {
      $query += $params;
    }

    $this->client = new RusaClient();
    $data   = $this->client->get($query);
    foreach ($data as $official) {
      $this->officials[$official->mid] = $official;
    }
  }

  public function addTitles() {
    // Get titles as well
    $query = ['dbname' => 'titles'];
    $data  = $this->client->get($query);
    foreach ($data as $title) {
      $title->midlist = explode(':', $title->midlist);
      $this->titles[$title->tid] = $title;
    }

    // Add tittles to offical
    foreach ($this->officials as $mid => $official) {
      foreach ($this->titles as $tid => $title) {
        if (in_array($mid, $title->midlist)) {
          $official->titles[] = $title->name;
        }
      }
    }
  }   

  /**
   * Get all officials
   *
   */
  public function getOfficials() {
    return $this->officials;
  } 

  /**
   * Get single official
   *
   */
  public function getOfficial($mid) {
    return $this->officials[$mid];
  }

  /** 
   * is Official?
   *
   * @return boolean
   *
   */
  public function isOfficial($mid) {
    return isset($this->officials[$mid]);
  }

  /**
   * Get title
   *
   */
  public function getTitles($mid) { 
    return $this->officials[$mid]->titles;
  }

}

