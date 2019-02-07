<?php

namespace Drupal\rusa_api\Client;

class RusaClient {
  /**
   */
  protected $httpClient;
  protected $base_uri;
  
  /**
   * Constructor.
   */
  public function __construct() {
    $this->httpClient = \Drupal::httpClient();
    $this->get_uri = "http://localhost/cgi-bin/gdbm2json.pl";
    $this->put_uri = "http://localhost/cgi-bin/post_routes.pl";
    //$this->get_uri = "https://linode.rusa.org/cgi-bin/gdbm2json.pl";
    //$this->put_uri = "https://linode.rusa.org//cgi-bin/post_routes.pl";
  }

  /**
   * Get the data from the back end
   *
   */
   public function get($query = NULL) {
     // Build up the query string if given
     // ----------------------------------
     $qstring = "";
     if (isset($query['dbname'])) {
       $qstring = '?' . $query['dbname'];
     }
     if (isset($query['key']) && isset($query['val'])) {
       $qstring .= "&" . $query['key'] . "=" . $query['val'];
     }

     // Get the response
     $response = $this->httpClient->get($this->get_uri . $qstring, ['verify' => FALSE] );
     $json     = $response->getBody();
     $data     = json_decode($json);
     return $data;
   }


  /**
   * Post the results to the back end
   *
   */
  public function put($data = []) {
    $json = json_encode($data);
    $request = $this->httpClient->post($this->put_uri , [
      'verify'    => FALSE,
      'json'      => $json,
    ]);
    return json_decode($request->getBody());

  }
}
