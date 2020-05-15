<?php

/**
 * @file
 *  RusaStates.php
 *
 * @Creted 
 *  2018-01-20 - Paul Lieberman
 *
 * RBA States
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets and hold state datas 
 *
 */
class RusaStates {

  protected $db_states;

  public function __construct() { 
    // Read state database
    $client = new RusaClient();
    $this->db_states =  $client->get(['dbname' => 'states']);
  }

  public function getStates() {
    // Build states array
    $states = [];
    foreach ($this->db_states as $state) {
      $states[$state->abbrev] = $state->name;
    }
    ksort($states);

    // Options to add additional, inclusive
    // 1 = territories
    // 2 = military
    // 3 = provinces
/*
    if ($option > 0) {
      // Add territories
      $states[] = '-- US Territories --';
      $states += $this->territories();
    }

    if ($option > 1) {
      // Add military POs 
      $states[] = '-- US Military PO -- ';
      $states += $this->military();
    }

    if ($option > 2) {
      // Add CA provinces
      $states[] = '-- Canadian Provinces --';
      $states += $this->provinces();
    }
*/
    return $states;
  }


  public function CodesByAbbrev() {
    $states = [];
    foreach ($this->db_states as $state) {
      $states[$state->abbrev] = $state->code;
    }
    // Add Puerto Rico
    $states['PR'] = 52;

    return $states;
  }
 
  public function NamesByCode() {
    $states = [];
    foreach ($this->db_states as $state) {
      $states[$state->code] = $state->name;
    }
    // Add Puerto Rico
    $states[52] = "Puerto Rico";

    return $states;
  }






  private function territories() {
    return [
      'AS'  => 'American Samoa', 
      'GU'  => 'Guam', 
      'MP'  => 'Northern Mariana Islands',
      'PR'  => 'Puerto Rico', 
      'VI'  => 'U.S. Virgin Islands',
    ];

  }

  private function military() {
    return [
      'AA'  => 'Military AA', 
      'AE'  => 'Military AE', 
      'AP'  => 'Military AP'
    ];

  }

  private function provinces() {
    return [
      'AB'  => 'Alberta',
      'BC'  => 'British Columbia', 
      'MB'  => 'Manitoba',
      'NB'  => 'New Brusnwick', 
      'NF'  => 'Newfoundland and Labrador', 
      'NS'  => 'Nova Scotia', 
      'ON'  => 'Ontario', 
      'PE'  => 'Prince Edward Island', 
      'QC'  => 'Quebec',
      'SK'  => 'Saskatchewan',
    ];
  }
}
