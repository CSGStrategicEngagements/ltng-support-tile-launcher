# Overview

This is a simple place to store items still to be done and items that could be done for this.

**1. Unit Tests for the Apex Classes**

This is a pre-requisite for making this available to go into production.

There are some challenges for how unit tests can be accomplished in an unknown production org that need to be thought through,
as the initial simple attempts were not successful. (These tests are made so much easier with a single production instance in mind)

We have been hearing requests from customers to have this "production ready," and would appreciate any pull requests to help in that regard.

Otherwise, like other requests, it will have to be triaged - as this is not an official product.

**2. Support 'Environment Specific' tiles**

Some tiles may only make sense within a mobile context, just like others may only make sense from a desktop.

Each of the Tile Launcher Entries could select from a multi-select picklist to specify which context they're available for
and the AuraEnabled request could support both the various
[$Browser form factors](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/expr_browser_value_provider.htm)
to only return back tiles that match the user's context.

This would be great for supporting [Apple's URL Schemes](https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html)
or [Android's URL Intents](https://developer.android.com/guide/components/intents-common)

**3. Alternative Saving Techniques**

Currently, we do not require a batch to run so that junction (preferences) for the user for all the available tiles are created beforehand.

(It frankly isn't feasible to setup from an automated standpoint currently - like through the Demo Setup)

This does introduce challenges as users can attempt to save order preferences for tiles without the knowledge of whether there already is a preference record for that tile or the tiles before (or after) - and ensuring that the sort order will remain accurate when the users come back.

Introducing a batch process to ensure a junction for all the tiles does not come without its drawbacks as users can get assigned to tiles (through custom preferences) throughout the day - so additional checks (like marking whether a specfic preference was found for a tile when returning the list) might be needed.

This also will create junctions for users that have never customized the tiles before (and may not need them) - increasing the footprint.

Further investigating each of these options may provide additional benefits (such as a shorter / safer save)

**4. Pagination of Saving for a safer save**

Related to the previous entry, it is a known issue that [Apex cannot accept an array of SObjects to an AuraEnabled method](https://success.salesforce.com/issues_view?id=a1p3A000000EAbLQAW&title=passing-an-apex-custom-object-parameter-type-from-an-aura-component-to-an-apex-controller-throws-an-error).  

We avoid this issue by sending JSON and decrypting JSON within APEX.

There are theoretical limits to the number of tiles that could be saved at a time (further investigation is needed as it appears based on the data volume).

Paginating the saves to only save chunks of 100 or so tiles at a time will provide a safer experience - but... the question is really whether this case is likely to occur.

It is currently not expected that users will have more tiles available to them than the current save process would support.
