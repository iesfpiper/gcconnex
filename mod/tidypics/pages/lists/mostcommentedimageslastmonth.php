<?php

/**
 * Most commented images of last month
 *
 */

// set up breadcrumbs
elgg_push_breadcrumb(elgg_echo('photos'), 'photos/siteimagesall');
elgg_push_breadcrumb(elgg_echo('tidypics:mostcommentedlastmonth'));

$offset = (int)get_input('offset', 0);
$limit = (int)get_input('limit', 16);

$start = strtotime("-1 months", mktime(0,0,0, date("m"), 1, date("Y")));
$end = mktime(0,0,0,date("m"), 0, date("Y"));

$db_prefix = elgg_get_config('dbprefix');
$options = array(
	'type' => 'object',
	'subtype' => 'image',
	'limit' => $limit,
	'offset' => $offset,
	'selects' => array("count( * ) AS views"),
	'joins' => array(
		"JOIN {$db_prefix}entities ce ON ce.container_guid = e.guid",
		"JOIN {$db_prefix}entity_subtypes cs ON ce.subtype = cs.id AND cs.subtype = 'comment'"),
	'wheres' => array("ce.time_created BETWEEN {$start} AND {$end}"),
	'group_by' => 'e.guid',
	'order_by' => "views DESC",
	'full_view' => false,
	'list_type' => 'gallery',
	'gallery_class' => 'tidypics-gallery'
);

$result = elgg_list_entities($options);

$title = elgg_echo('tidypics:mostcommentedlastmonth');

if (elgg_is_logged_in()) {
	$logged_in_guid = elgg_get_logged_in_user_guid();
	elgg_register_menu_item('title', array(
		'name' => 'addphotos',
		'href' => "ajax/view/photos/selectalbum/?owner_guid=" . $logged_in_guid,
		'text' => elgg_echo("photos:addphotos"),
		'link_class' => 'elgg-button elgg-button-action elgg-lightbox'
	));
}

// only show slideshow link if slideshow is enabled in plugin settings and there are images
if (elgg_get_plugin_setting('slideshow', 'tidypics') && !empty($result)) {
	elgg_require_js('tidypics/slideshow');
	$url = elgg_get_site_url() . "photos/mostcommentedlastmonth?limit=64&offset=$offset&view=rss";
	$url = elgg_format_url($url);
	elgg_register_menu_item('title', array(
		'name' => 'slideshow',
		'id' => 'slideshow',
		'data-slideshowurl' => $url,
		'href' => '#',
		'text' => "<img src=\"".elgg_get_site_url() ."mod/tidypics/graphics/slideshow.png\" alt=\"".elgg_echo('album:slideshow')."\">",
		'title' => elgg_echo('album:slideshow'),
		'link_class' => 'elgg-button elgg-button-action'
	));
}

if (!empty($result)) {
	$area2 = $result;
} else {
	$area2 = elgg_echo('tidypics:mostcommentedlastmonth:nosuccess');
}
$body = elgg_view_layout('content', array(
	'filter_override' => '',
	'content' => $area2,
	'title' => $title,
	'sidebar' => elgg_view('photos/sidebar_im', array('page' => 'all')),
));

// Draw it
echo elgg_view_page(elgg_echo('tidypics:mostcommentedlastmonth'), $body);
