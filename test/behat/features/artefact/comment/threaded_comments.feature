@javascript @core @core_artefact @core_content @artefact_comment
Feature: Threaded comments
   In order to allow private conversations between an instructor and student on a student's page
   As a teacher I need to have a private thread on the student's page
   So I can post things only they can see, and they can post private replies to it

Background:
    Given the following "institutions" exist:
     | name | displayname | commentthreaded | allowinstitutionpublicviews |
     | instone | inst1 | 1 | 1 |
    Given the following "users" exist:
     | username | password | email | firstname | lastname | institution | authname | role |
     | pageowner | password | test01@example.com | Paige | Owner | instone | internal | admin |
     | pagecommenter | password | test02@example.com | Paget | Commenter | mahara | internal | admin |
     | pagewatcher | password | test03@example.com | Pagey | Follower | mahara | internal | admin |
    Given the following "pages" exist:
     | title | description | ownertype | ownername |
     | page1 | page1 | user | pageowner |
    Given the following "permissions" exist:
     | title | accesstype | accessname | allowcomments | approvecomments |
     | page1 | public | public | 1 | 0 |

Scenario: Public comment by page owner, public reply by third party
    Given I log in as "pageowner" with password "password"
    And I go to portfolio page "page1"
    And I fill in "Public comment by pageowner" in editor "Comment"
    And I enable the switch "Make public"
    And I press "Comment"
    And I log out
    And I log in as "pagecommenter" with password "password"
    And I go to portfolio page "page1"
    And I click on "Reply" in "Public comment by pageowner" row
    # I should see a preview of the reply-to comment below the feedback form
    And I should see "Public comment by pageowner" in the ".commentreplyview" "css_element"
    And I fill in "Public reply by pagecommenter" in editor "Comment"
    When I press "Comment"
    Then I should see "Public comment by pageowner"
    And I should see "Public reply by pagecommenter"

Scenario: Public comment by non-owner, owner can private reply, another non-owner cannot private reply
    Given I log in as "pagecommenter" with password "password"
    And I go to portfolio page "page1"
    And I fill in "Public comment by pagecommenter" in editor "Comment"
    And I enable the switch "Make public"
    And I press "Comment"
    And I log out
    And I log in as "pageowner" with password "password"
    And I go to portfolio page "page1"
    And I click on "Reply" in "Public comment by pagecommenter" row
    And I disable the switch "Make public"
    And I fill in "Private reply by pageowner" in editor "Comment"
    And I press "Comment"
    And I log out
    And I log in as "pagewatcher" with password "password"
    And I go to portfolio page "page1"
    And I click on "Reply" in "Public comment by pagecommenter" row
    # I should not be able to make a private reply to a comment by someone other than the page owner
    And I should see "Public" in the "#add_feedback_form_ispublic_container" "css_element"
    When I fill in "Public reply by pagewatcher" in editor "Comment"
    And I press "Comment"
    Then I should see "Public comment by pagecommenter"
    And I should not see "Private reply by pageowner"
    And I should see "Public reply by pagewatcher"

Scenario: Private comment by commenter, private reply by page owner, private counter-reply by page commenter
    Given I log in as "pagecommenter" with password "password"
    And I go to portfolio page "page1"
    And I fill in "Private comment by pagecommenter" in editor "Comment"
    And I disable the switch "Make public"
    And I press "Comment"
    And I press "More..."
    And I follow "Remove page from watchlist"
    And I log out
    And I log in as "pageowner" with password "password"
    And I go to portfolio page "page1"
    And I click on "Reply" in "Private comment by pagecommenter" row
    # There should be no option to make a public reply to a private comment
    And I should see "Private" in the "#add_feedback_form_ispublic_container" "css_element"
    And I fill in "Private reply by pageowner" in editor "Comment"
    And I press "Comment"
    And I log out
    And I log in as "pagecommenter" with password "password"
    And I go to portfolio page "page1"
    # I should be able to see the pageowner's private reply to my private comment
    # (An exception to the general rule that only the pageowner can see private comments)
    And I should see "Private reply by pageowner"
    And I click on "Reply" in "Private reply by pageowner" row
    And I fill in "Private counter-reply by pagecommenter" in editor "Comment"
    When I press "Comment"
    Then I should see "Private comment by pagecommenter"
    And I should see "Private reply by pageowner"
    And I should see "Private counter-reply by pagecommenter"
    # pagecommenter should receive a notification about pageowner's reply even though they unwatched the page
    And I choose "mail" from user menu by id
    And I follow "New comment on page1"
    And I should see "Private reply by pageowner"

Scenario: No private replies to anonymous comments
    Given I go to portfolio page "page1"
    And I fill in "Name" with "Anonymous User"
    # No WYSIWYG editor for anonymous users
    And I fill in "Comment" with "Public comment by anonymous user"
    And I enable the switch "Make public"
    And I press "Comment"
    When I log in as "pagecommenter" with password "password"
    And I go to portfolio page "page1"
    And I click on "Reply" in "Public comment by anonymous user" row
    # I should not be able to make a private reply to a comment by someone other than the page owner
    Then I should see "Public" in the "#add_feedback_form_ispublic_container" "css_element"
    And I fill in "Public reply by pagecommenter" in editor "Comment"
    And I press "Comment"
    And I should see "Public comment by anonymous user"
    And I should see "Public reply by pagecommenter"

Scenario: No replies to deleted comments
    Given I log in as "pageowner" with password "password"
    And I go to portfolio page "page1"
    And I fill in "I will delete this comment" in editor "Comment"
    And I enable the switch "Make public"
    When I press "Comment"
    And I should see "I will delete this comment"
    And I delete the "I will delete this comment" row
    # No reply button, because I have deleted the comment
    Then I should not see "Reply"

Scenario: Deleted comments
    Given I log in as "pageowner" with password "password"
    And I go to portfolio page "page1"
    # Create a tree of comments like so:
    #
    # * Comment #1
    # ** Comment #1/1
    # *** Comment #1/2
    # * Comment #2
    #
    And I fill in "Comment 1." in editor "Comment"
    And I press "Comment"
    And I should see "Comment 1."
    And I fill in "Comment 2." in editor "Comment"
    And I press "Comment"
    And I should see "Comment 2."
    And I click on "Reply" in "Comment 1." row
    And I fill in "Comment 1-1." in editor "Comment"
    And I press "Comment"
    And I should see "Comment 1-1."
    # TODO: fix "I click on" so it automatically scrolls if needed
    And I scroll to the base of id "commentreplyto20"
    And I click on "Reply" in "Comment 1-1." row
    And I fill in "Comment 1-2." in editor "Comment"
    And I press "Comment"
    And I should see "Comment 1-2."

    # Deleting a threaded comment that has a reply, display
    # a placeholder for the reply's context
    #
    # * Comment #1
    # ** (Deleted placeholder)
    # *** Comment #1/2
    # * Comment #2
    #
    # TODO: Fix "I delete the row" so it automatically scrolls if needed
    When I scroll to the base of id "delete_comment20_delete_comment_submit"
    And I delete the "Comment 1-1." row
    Then I should not see "Comment 1-1."
    And I should see "Comment removed by the author"

    # Deleting a comment with no replies, hide the deleted
    # comment. (Recursively also hide any deleted
    # parents that now have no visible replies.)
    #
    # * Comment #1
    # * Comment #2
    #
    # TODO: Fix "I delete the row" so it automatically scrolls if needed
    When I scroll to the base of id "delete_comment21_delete_comment_submit"
    And I delete the "Comment 1-2." row
    Then I should not see "Comment 1-2."
    And I should not see "Comment removed by the author"
