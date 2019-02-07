Drupal.behaviors.rusaApi = {
  attach: function (context, settings) {
    if (typeof jQuery.fn.chosen === "function") {
      jQuery('select').chosen();
    }

    jQuery(".rusa-inactive").parents( "tr" ).addClass("rusa-inactive");
  }
};
