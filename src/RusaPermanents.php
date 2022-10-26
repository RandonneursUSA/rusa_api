<?php

/**
 * @file
 *  RusaPermanents.php
 *
 * @Creted 
 *  2018-02023 - Paul Lieberman
 *
 * Gets and holds Permanent data
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets and holds perm data
 *
 */
class RusaPermanents {

  protected $perms;

  public function __construct($params = []) {
    $query = ['dbname' => 'permanents'];
    if (!empty($params['key']) && !empty($params['val'])) {
      $query += $params;
    }

    // Get perms from gdbm
    $client    = new RusaClient();
    $db_perms =  $client->get($query);

    foreach ($db_perms as $perm) {
      $this->perms[$perm->pid] = $perm;
    }  

  }

  /**
   * Get all Permanents
   *
   */
  public function getPermanents(){
    return $this->perms;
  }

  /**
   * Get active Permanents
   *
   */
  public function getActivePermanents(){
    $perms = [];
    foreach ($this->perms as $pid => $perm) {
      if ($perm->status == '1') {
        $perms[$pid] = $perm;
      }
    }
    return $perms;

  }

  /**
   * Get single Permanent by id
   *
   */
  public function getPermanent($pid){
    return $this->perms[$pid];
  }


 /** Get Permanents by distance
   *
   * Filter in 100km increments
   */
  public function getPermanentsByDistance($dist){
    // using the same distance ranges as in the Perl perm search page
    $dist_range = [100 => 199, 200 => 299, 300 => 399, 400 => 599, 600 => 40000];
    $results = [];
    foreach ($this->perms as $pid => $perm) {
      // in unlikely case $dist_range[$dist] does not exist, compare to $dist+99 instead to avoid error
      if ($perm->dist >= $dist && $perm->dist <= ($dist_range[$dist] ?? ($dist+99))) {
        $results[$pid] = $perm;
      }
    }
    return $results;
  }

  /**
   * Get single Permanent distance
   *
   */
  public function getPermanentDistance($pid){
    return $this->perms[$pid]->dist;
  }

  /**
   * Get perm line
   *
   * Combines distance, perm name, and start into a string
   *
   */
  public function getPermanentLine($pid) {
    $perm = $this->perms[$pid];

    $perm_name = empty($perm->name) ? "Unnamed perm" : $perm->name;
    $perm_line = "Permanent: " .  $pid .  " (" . $perm->dist . "km) " .  "\"" . $perm_name . "\"  " .  $perm->start;
   
    return $perm_line;
  }

  /**
   * Get perms sorted by distance and id
   *
   */
  public function getPermanentsSorted() {
    $perms = $this->perms;

    // Sort by distance and then perm id
    foreach ($perms as $key => $perm) {
      $asort[$key] = $perm->dist;
      $bsort[$key] = $perm->pid;;
    }

    array_multisort($asort, SORT_NUMERIC, SORT_ASC,
                    $bsort, SORT_NUMERIC, SORT_ASC,
                    $perms);
    return $perms;
  }


/**
   * Get perms sorted by location and distance
   *
   */
  public function getPermanentsSortedByLocation() {
    $perms = $this->perms;

    // Sort by State and then start location
    foreach ($perms as $key => $perm) {
      $asort[$key] = $perm->startstate;
      $bsort[$key] = $perm->startcity;
      $csort[$key] = $perm->dist;
    }

    array_multisort($asort, SORT_STRING, SORT_ASC,
                    $bsort, SORT_STRING, SORT_ASC,
                    $csort, SORT_NUMERIC, SORT_ASC,
                    $perms);
    return $perms;
  }


  /**
   * Get perms by owner
   *
   */
  public function getPermsByOwner($mid) {
    $perms = [];
    foreach ($this->perms as $pid => $perm) {
      if ($perm->mid == $mid && $perm->status == '1') {
        $perms[$pid] = $perm;
      }
    }
    return $perms;
  }
  
    /**
     * Is perm inactive
     *
     */
    public function isInactive($pid){
        $perm = $this->perms[$pid];
        return ! ($perm->status === '1');   
   }

    /**
     * Is perm an SR
     *
     */
    public function isSr($pid){
        $perm = $this->perms[$pid];
        return ($perm->superrand === '1');   
   }

    /**
     * Get Perms by type
     *
     */
    public function getPermanentsByType($type) {
        if (in_array($type, ['LOOP', 'OB', 'PP'])) {
            $perms = [];
            foreach ($this->perms as $pid => $perm) {
                if ($perm->type == $type) {
                    $perms[$pid] = $perm;
                }
            }
            return $perms;
        }
    }


    /**
     * Get Perms by name
     *
     */
    public function getPermanentsByName($name) {
        if (! empty($name)) {
            $perms = [];
            foreach ($this->perms as $pid => $perm) {
                if (stripos($perm->name, $name) !== FALSE) {             
                    $perms[$pid] = $perm;
                }
            }
            return $perms;
        }
    }
    
    
    /**
     * Get permanents query
     *
     */
    public function getPermanentsQuery($query) {
    
        if ($query['active']) {
            $this->perms = $this->getActivePermanents();
        }
        
        if ($query['nosr']) {        
            // Remove SR600s
            foreach ($this->perms as $pid => $perm) {
                if ($perm->superrand != '1') {
                    $perms[$pid] = $perm;
                }
            }
            $this->perms = $perms;
        }
        
        if (isset($query['dist'])) {
            $this->perms = $this->getPermanentsByDistance($query['dist']);
        }
        
        if (isset($query['type'])) {
            $this->perms = $this->getPermanentsByType($query['type']);
        }
        
        if (isset($query['name'])) {
            $this->perms = $this->getPermanentsByName($query['name']);
        }
     
        return $this->getPermanentsSortedByLocation();
    }




} // End of class
