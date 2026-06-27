;;; GNU Guix --- Functional package management for GNU
;;;
;;; This file is NOT part of GNU Guix.
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(simple-service 'my-dns
                    hosts-service-type
                    (list (host "10.0.0.1"
                                "network"
                                "network.internal")
                          (host "10.0.0.50"
                                "node"
                                "node.internal")))

(simple-service 'my-redirect
                    hosts-service-type ;; To-do add TLD list for big services.
                    (list (host ""
                                "bandcamp.com") ;; Tent
                          (host "" ;; libremdb.privacyredirect.com
                                "imdb.com") ;; libremdb
                          (host ""
                                "imgur.com") ;; Rimgo
                          (host ""
                                "instagram.com") ;; Proxigram
                          (host ""
                                "reddit.com") ;; Teddit
                          (host ""
                                "reuters.com") ;; Neuters
                          (host ""
                                "maps.google.com") ;; OpenStreetMaps
                          (host ""
                                "bing.com"
                                "google.com") ;; Searxng - priv.au
                          (host "" ;; anonymousoverflow.privacyredirect.com
                                "stackoverflow.com") ;; AnonymousOverflow
                          (host "" 
                                "tiktok.com") ;; ProxiTok 
                          (host ""
                                "wikipedia.com") ;; wikiless
                          (host "109.107.190.203" ;; nitter.privacyredirect.com
                                "x.com"
                                "twitter.com") ;; Nitter
                          (host "200.14.81.226" ;; inv.nadeko.net
                                "youtube.com")))

(simple-service 'my-adblock
                    hosts-service-type
                    (list (host "0.0.0.0"
                                "")))


;;; hosts.scm ends here
