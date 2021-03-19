<?php

namespace Drupal\rusa_api\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

/**
 * Configure Rusa api settings for this site.
 */
class RusaApiSettingsForm extends ConfigFormBase {

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'rusa_api_rusa_api_settings';
  }

  /**
   * {@inheritdoc}
   */
  protected function getEditableConfigNames() {
    return ['rusa_api.settings'];
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
   
	$config = $this->config('rusa_api.settings');
   
   
	// RUSA API Key
	$form['api_key'] = [
		'#type' => 'key_select',
		'#title' => $this->t('RUSA API Key'),
		'#default_value' => $config->get('api_key'),
	];

    return parent::buildForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function validateForm(array &$form, FormStateInterface $form_state) {
    
    if ($form_state->getValue('api_key') === '') {
      $form_state->setErrorByName('api_key', $this->t('The value is not correct.'));
    }
    parent::validateForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    $this->config('rusa_api.settings')
      ->set('api_key', $form_state->getValue('api_key'))
      ->save();
    parent::submitForm($form, $form_state);
  }

}
