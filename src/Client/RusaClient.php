<?php

namespace Drupal\rusa_api\Client;

use Drupal\Core\Url;


/**
 * The RusaClient class provides the http interface between Drupal and the Perl backend
 *
 */
class RusaClient {
  
    protected $httpClient; 
    protected $get_uri;
    protected $put_uri;
    protected $results_uri;
    protected $pay_uri;
    protected $get_results;

    /**
     * Constructor.
     * - Instantiate client
     * - Get host
     * - Set paths from routes
     *
     */
    public function __construct() {
        $this->httpClient = \Drupal::httpClient();
        $host = \Drupal::request()->getHost();

        $this->get_uri     = 'https://' . $host . Url::fromRoute('get_uri')->toString();
        $this->put_uri     = 'https://' . $host . Url::fromRoute('put_uri')->toString();
        $this->results_uri = 'https://' . $host . Url::fromRoute('results_uri')->toString();
        $this->pay_uri     = 'https://' . $host . Url::fromRoute('pay_uri')->toString();
        $this->get_results = 'https://' . $host . Url::fromRoute('get_results')->toString();
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
        $request = $this->httpClient->post($this->put_uri, [
                'verify'    => FALSE,
                'json'      => $json,
        ]);
        return json_decode($request->getBody());
    }

    /**
     * Get the Resultsfrom the back end
     *
     */
    public function getResults($query = NULL) {
        if (! $query) {
        return;
        }
        $qstring = '?' . $query;

        // Get the response
        $response = $this->httpClient->get($this->get_results . $qstring, ['verify' => FALSE] );
        $json     = $response->getBody();
        $data     = json_decode($json);
        return $data;
    }


    /**
     * Post Perm Results
     *
     */
    public function post_perm_results($data = []) {
    
        //  Send as a form    
        $request = $this->httpClient->post($this->results_uri,
            [
                'verify'      => FALSE,
                'form_params' => $data,
                'headers' => [
                    'Content-type' => 'application/x-www-form-urlencoded',
                ],
            ]);
        return json_decode($request->getBody());

    }



    /**
     * Post perm prog payment
     *
     */
    public function perm_pay($data = []) {
        $json = json_encode($data);
        $request = $this->httpClient->post($this->pay_uri, [
                'verify'    => FALSE,
                'json'      => $json,
        ]);
        return json_decode($request->getBody());
    }

} //End of Class
