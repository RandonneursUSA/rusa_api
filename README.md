Custom Drupal module for rusa.org
Author: Paul Lieberman

Moved to github/RandonneursUSA May 3, 2022 - PL - MFT

This module includes classes and methods used by all of the other rusa/ modules, mainly for database interaction. The Client classes currently use the GDBM2JSON gateway to get data from the GDBM files. In theory these could just be swapped for classes that use the entity API once the data is in Drupal, and none of the others would have to change.

# Classes
--------------------

RusaApiForm     - Early development work, can be deleted
RusaClubs       - Methods to get club data 
RusaCountries   - Methods to get country data
RusaEvents      - Methods to get events data
RusaMembers     - Methods to get member data
RusaMessages    - A class for all textual messages. Hasn't worked out yet, but a good idea
RusaOfficials   - Methods to get official data
RusaPermanents  - Methods to get permanent data
RusaRegions     - Methods to get region data
RusaResults     - Methods to get results data
RusaResultsSlow - Original attempt to get results was way too slow
RusaRoutes      - Methods to get routes data
RusaStates      - Methods to get states data

Client/RusaClient        - The main interface to the GDBM data
Client/RusaResultsClient - Results needed a special case because they are so convoluted

Plugin/rest/resource/RusaApiResource - Early attempt at defining a REST resource. Not yet ready for prime time.

These were removed - https://rusa.org/bugzilla/show_bug.cgi?id=1053 
-- Form/RusaClubsForm   - Query form. Not really part of the API and not being used.
-- Form/RusaMembersForm - Query form. Not really part of the API and not being used.
-- Form/RusaRegionsForm - Query form. Not really part of the API and not being used.

# To-Do
------------------------------------
I discovered today (January 14, 2024) that this module may be doing things bass-ackwards
The rusa_user module in producing 'My RUSA Info' instantiates three classes
    RusaMembers
    RusaClubs
    RusaOfficials
 and each of these in turn are instantiating a RusaClient to get the data. 
 Indeed the RusaClient is protected and can not be instantiated directly from another module.
 The inefficiency is that the RusaClient is instantiating an new Guzzle\HttpClient each time.
 It is possible that Drupal (or Symphony) is reusing the same one. I don't really know.
 And I don't know if it is worth re-engineering the module to just have one entry point for consumers in order to avoid this.



