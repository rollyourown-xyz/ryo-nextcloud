<?php
// SPDX-FileCopyrightText: 2022 Nextcloud GmbH
// SPDX-License-Identifier: AGPL-3.0-or-later
$CONFIG = array (
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'filelocking.enabled' => true,
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => [
    'host'     => 'localhost',
    'port'     => 6379,
    'dbindex'  => 0,
    'timeout'  => 1.5,
  ],
);
