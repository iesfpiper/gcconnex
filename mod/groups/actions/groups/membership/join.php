<?php
/**
 * Join a group
 *
 * Three states:
 * open group so user joins
 * closed group so request sent to group owner
 * closed group with invite so user joins
 *
 * @package ElggGroups
 */

global $CONFIG;

$user_guid = get_input('user_guid', elgg_get_logged_in_user_guid());
$group_guid = get_input('group_guid');

$user = get_user($user_guid);

// access bypass for getting invisible group
$ia = elgg_set_ignore_access(true);
$group = get_entity($group_guid);
elgg_set_ignore_access($ia);

if ($user && ($group instanceof ElggGroup)) {

	// join or request
	$join = false;
	if ($group->isPublicMembership() || $group->canEdit($user->guid)) {
		// anyone can join public groups and admins can join any group
		$join = true;
	} else {
		if (check_entity_relationship($group->guid, 'invited', $user->guid)) {
			// user has invite to closed group
			$join = true;
		}
	}

	if ($join) {
		if (groups_join_group($group, $user)) {


			// cyu - 05/12/2016: modified to comform to the business requirements documentation
			if (elgg_is_active_plugin('cp_notifications')) {
				$user = elgg_get_logged_in_user_entity();
				add_entity_relationship($user->getGUID(), 'cp_subscribed_to_email', $group->getGUID());
				add_entity_relationship($user->getGUID(), 'cp_subscribed_to_site_mail', $group->getGUID());
			}

			system_message(elgg_echo("groups:joined"));
			forward(REFERER); //changed from $group->getURL() - Ethan 08/24/2016
		} else {
			register_error(elgg_echo("groups:cantjoin"));
		}
	} elseif (check_entity_relationship($user->guid, 'membership_request', $group->guid)) {
		register_error(elgg_echo("groups:joinrequest:exists"));
	} else {
		add_entity_relationship($user->guid, 'membership_request', $group->guid);

		$owner = $group->getOwnerEntity();

		$url = "{$CONFIG->url}groups/requests/$group->guid";

		$subject = elgg_echo('groups:request:subject', array(
			$user->name,
			$group->name,
		), $owner->language);

		$body = elgg_echo('groups:request:body', array(
			$group->getOwnerEntity()->name,
			$user->name,
			$group->name,
			$user->getURL(),
			$url,
		), $owner->language);

		$params = [
			'action' => 'membership_request',
			'object' => $group,
		];
		
		// Notify group owner
		if (notify_user($owner->guid, $user->getGUID(), $subject, $body, $params)) {
			system_message(elgg_echo("groups:joinrequestmade"));
		} else {
			register_error(elgg_echo("groups:joinrequestnotmade"));
		}
	}
} else {
	register_error(elgg_echo("groups:cantjoin"));
}

forward(REFERER);
