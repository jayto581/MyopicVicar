# Copyright 2012 Trustees of FreeBMD
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Be sure to restart your server when you modify this file.
MyopicVicar::Application.config.server_upgrade ?  expiry_time = 3.seconds : expiry_time= nil
case MyopicVicar::Application.config.freexxx_display_name
when 'FreeCEN'
  MyopicVicar::Application.config.session_store :cookie_store, key: 'FreeCEN_session', expire_after: expiry_time #480.minutes
when 'FreeREG'
  MyopicVicar::Application.config.session_store :cookie_store, key: 'FreeREG_session', expire_after: expiry_time #480.minutes
when 'FreeBMD'
  MyopicVicar::Application.config.session_store :cookie_store, key: 'FreeBMD_session', expire_after: nil #480.minutes
end

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# MyopicVicar::Application.config.session_store :active_record_store
