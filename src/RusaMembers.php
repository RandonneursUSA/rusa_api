<?php

/**
 * @file
 *  RusaMembers.php
 *
 * @Creted 
 *  2018-01-09 - Paul Lieberman
 *
 * RusaMembers
 *
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets and holds members data
 *
 */
class RusaMembers {

  protected $client;
  protected $members;

  public function __construct($params = []) {
    $this->client  = new RusaClient();
    $query   = ['dbname' => 'members'];

    // If we are passed a key/value
    if (!empty($params['key']) && !empty($params['val'])) {
     $query += $params;
    }
    // Get the data
    $data = $this->client->get($query);

    // Store keyed on acpcode
    foreach ($data as $member) {
      $this->members[$member->mid] = $member;
    }

    // Sort by mid
    ksort($this->members);
  }

  /*
   * addTitles
   *
   * Get titles for each member
   *
   */
  public function addTitles() {
    // Get titles as well
    $query = ['dbname' => 'titles'];
    $data  = $this->client->get($query);
    foreach ($data as $title) {
      $title->midlist = explode(':', $title->midlist);
      $this->titles[$title->tid] = $title;
    }

    // Add tittles to members
    foreach ($this->members as $mid => $member) {
      foreach ($this->titles as $tid => $title) {
        if (in_array($mid, $title->midlist)) {
          $member->titles[] = $title->name;
        }
      }
    }
  }

  /**
   * Get all the members
   *
   */
  public function getMembers(){
    return $this->members;
  }

  /**
   * Get a single member
   *
   */
  public function getMember($mid = '') {
    if (!empty($mid)) {
      return $this->members[$mid];
    }
    else {
      // If no member ID return the name of the first or only member
      return $this->members[array_keys($this->members)[0]];
    }
  }

  /**
   * Check for valid ID
   *
   */
  public function isValid($mid) {
    return !empty($this->members[$mid]);
  }

   /**
    * Check for expired ID
    *
    */
   public function isExpired($mid) {
     $member = $this->members[$mid];
     return date("Y-m-d") > $member->expdate;
   }

  /**
   * Check for volunteer
   *
   */
  public function isVolunteer($mid) {
    return !empty($this->members[$mid]->titles);
  }

} // End of class


