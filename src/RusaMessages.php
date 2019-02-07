<?php
/*
 * Rusa Messages
 *
 * Author: Paul Lieberman
 * Created: 29-Jan-2018
 *
 * Consolidate messages into a single class for easy editing.
 */


namespace Drupal\rusa_api;

class RusaMessages {

  protected $messsages;


  public function __construct() {
    // Set messages here

    $this->messages['auth'] = "<p>An RBA can use this form to assign routes to events that have already been schedulede, or to " .
          "change routes for events that already have a route assigned.</p>" .
          "<p>Select your region below and provide your member ID and your club's ACP code.</p>";
   
    $this->messages['instruct'] = "<p>For all events you can assign or change the route here.<br />" . 
          "For RUSA events you can set the event distance to use the orignal distance that was set in the schedule, " .
          "or the route distance for the route you select here.</p>" .
          "<p>When you submit this form you will see another screen where you can confirm your updates before the Ride Calendar is committed.</p>";
    
    $this->messages['review'] = "<p>Please review your changes here. Events that have been changed are shown in <b>bold face</b>.<br />" .
          "When you submit this form your changes will be committed to the RUSA Calendar.</p>";

    $this->messages['post_err'] =  "The server retured an error when posting your changes. The message is: <br />";

    $this->messages['post_success'] = "Your changes have been saved.";

    $this->messages['dist'] = "Calendared distance cannot be greater than Route distance. " .
                "Please select 'Use route distance' or select a different route";


  }

  public function getMessage($key){
    return $this-t($messages[$key]);
  }

}
