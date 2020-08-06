<?php

namespace Drupal\rusa_api;

use Drupal\Core\Messenger;
use Drupal\taxonomy\Entity\Term;

class RusaStatesBuild {

  public function buildStates() {
    $states = $this->getStates();
    $messenger = \Drupal::messenger();

    foreach ($states as $st => $state) {
      $messenger->addMessage(t("Adding term " . $state['name']), $messenger::TYPE_STATUS);
      
      $term = Term::create(array(
        'parent'                    => array(),
        'name'                      => $state['name'],
        'vid'                       => 'states',
        'field_state_abbreviation'  => $st,
        'field_state_code'          => $state['code'],
        ));
      $term->save();
    }
  }

   
  public function getStates() {
    $states = array();
    $states['AK'] = array('name' => 'Alaska', 'code' => '02');
    $states['AL'] = array('name' => 'Alabama', 'code' => '01');
    $states['AR'] = array('name' => 'Arkansas', 'code' => '04');
    $states['AZ'] = array('name' => 'Arizona', 'code' => '03');
    $states['CA'] = array('name' => 'California', 'code' => '05');
    $states['CO'] = array('name' => 'Colorado', 'code' => '06');
    $states['CT'] = array('name' => 'Connecticut', 'code' => '07');
    $states['DC'] = array('name' => 'D.C.', 'code' => '51');
    $states['DE'] = array('name' => 'Delaware', 'code' => '08');
    $states['FL'] = array('name' => 'Florida', 'code' => '09');
    $states['GA'] = array('name' => 'Georgia', 'code' => '10');
    $states['HI'] = array('name' => 'Hawaii', 'code' => '11');
    $states['IA'] = array('name' => 'Iowa', 'code' => '15');
    $states['ID'] = array('name' => 'Idaho', 'code' => '12');
    $states['IL'] = array('name' => 'Illinois', 'code' => '13');
    $states['IN'] = array('name' => 'Indiana', 'code' => '14');
    $states['KS'] = array('name' => 'Kansas', 'code' => '16');
    $states['KY'] = array('name' => 'Kentucky', 'code' => '17');
    $states['LA'] = array('name' => 'Louisiana', 'code' => '18');
    $states['MA'] = array('name' => 'Massachusetts', 'code' => '21');
    $states['MD'] = array('name' => 'Maryland', 'code' => '20');
    $states['ME'] = array('name' => 'Maine', 'code' => '19');
    $states['MI'] = array('name' => 'Michigan', 'code' => '22');
    $states['MN'] = array('name' => 'Minnesota', 'code' => '23');
    $states['MO'] = array('name' => 'Missouri', 'code' => '25');
    $states['MS'] = array('name' => 'Missisippi', 'code' => '24');
    $states['MT'] = array('name' => 'Montana', 'code' => '26');
    $states['NC'] = array('name' => 'North Carolina', 'code' => '33');
    $states['ND'] = array('name' => 'North Dakota', 'code' => '34');
    $states['NE'] = array('name' => 'Nebraska', 'code' => '27');
    $states['NH'] = array('name' => 'New Hampshire', 'code' => '29');
    $states['NJ'] = array('name' => 'New Jersey', 'code' => '30');
    $states['NM'] = array('name' => 'New Mexico', 'code' => '31');
    $states['NV'] = array('name' => 'Nevada', 'code' => '28');
    $states['NY'] = array('name' => 'New York', 'code' => '32');
    $states['OH'] = array('name' => 'Ohio', 'code' => '35');
    $states['OK'] = array('name' => 'Oklahoma', 'code' => '36');
    $states['OR'] = array('name' => 'Oregon', 'code' => '37');
    $states['PA'] = array('name' => 'Pennsylvania', 'code' => '38');
    $states['RI'] = array('name' => 'Rhode Island', 'code' => '39');
    $states['SC'] = array('name' => 'South Carolina', 'code' => '40');
    $states['SD'] = array('name' => 'South Dakota', 'code' => '41');
    $states['TN'] = array('name' => 'Tennessee', 'code' => '42');
    $states['TX'] = array('name' => 'Texas', 'code' => '43');
    $states['UT'] = array('name' => 'Utah', 'code' => '44');
    $states['VA'] = array('name' => 'Virginia', 'code' => '46');
    $states['VT'] = array('name' => 'Vermont', 'code' => '45');
    $states['WA'] = array('name' => 'Washington', 'code' => '47');
    $states['WI'] = array('name' => 'Wisconsin', 'code' => '49');
    $states['WV'] = array('name' => 'West Virginia', 'code' => '48');
    $states['WY'] = array('name' => 'Wyoming', 'code' => '50');
    
    return $states;
  }
}
