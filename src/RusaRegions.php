<?php

/**
 * @file
 *  RusaRegions.php
 *
 * @Creted 
 *  2018-01-09 - Paul Lieberman
 *
 * Get Regions from database
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets and holds regions data
 *
 */
class RusaRegions {

  protected $regions;
  protected $selected_region;

  public function __construct($params = []) {
    $client = new RusaClient();

    $query = ['dbname' => 'regions'];
    if (!empty($params['key']) && !empty($params['val'])) {
      $query += $params;
    }

    // Get the regions 
    $db_regions  =  $client->get($query);
    foreach ($db_regions as $region) {
      $this->regions[$region->regid] = $region;
    }
  }

  /**
   * Get all Regions
   *
   */
  public function getRegions(){
    return $this->regions;
  }

  /**
   * Get a single Region by id
   *
   */
  public function getRegion($regid){
    return $this->regions[$regid];
  }

  /**
   * Set selected region
   *
   */
  public function setSelectedRegion($regid){
    $this->selected_region = $regid;
  }

  /**
   * Get selected region
   *
   */
  public function getSelectedRegion(){
    return $this->regions[$this->selected_region];
  }

  /**
   * Get selected region ID
   *
   */
  public function getSelectedRegionId(){
    return $this->selected_region;
  }

  /**
   * Get Regions with city and state
   *
   */
  public function getRegionsStateCity() {
    $options = [];
    foreach ($this->regions as $regid => $region) {
      $options[$regid] = $region->state . ': ' . $region->city;
    }
    // Sort the regions by state
    asort($options);

    return $options;
  }

  /**
   * Get regions for RBA
   *
   * @param integer $rbaid
   *
   */
  public function getRegionsByRba($rbaid) {
    $rba_regions = [];
    foreach ($this->regions as $regid => $region) {
      if ($region->rbaid == $rbaid) {
        $rba_regions[$regid] = $region;
      }
    }
    return $rba_regions;
  }



} // End of class

