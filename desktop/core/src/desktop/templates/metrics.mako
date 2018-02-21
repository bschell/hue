## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
from desktop import conf
%>

<%
MAIN_SCROLLABLE = is_embeddable and "'.page-content'" or "window"
if conf.CUSTOM.BANNER_TOP_HTML.get():
  TOP_SNAP = is_embeddable and "78px" or "106px"
else:
  TOP_SNAP = is_embeddable and "50px" or "106px"
%>

<%namespace name="actionbar" file="actionbar.mako" />
<%namespace name="layout" file="about_layout.mako" />

%if not is_embeddable:
${ commonheader(_('Metrics'), "about", user, request) | n,unicode }
%endif


<script type="text/javascript">
  (function () {
    var MetricsViewModel = function () {
      var self = this;

      self.metrics = ${metrics | n,unicode};
      self.metricsKeys = ko.observableArray(Object.keys(self.metrics).sort());
      self.selectedMetric = ko.observable('All');
      self.metricsFilter = ko.observable();
      self.filteredMetrics = ko.pureComputed(function () {
        if (self.metricsFilter()) {
          var lowerQuery = self.metricsFilter().toLowerCase();
          var result = {};
          Object.keys(self.metrics).forEach(function (key) {
            var filteredSubMetric = {};
            var atleastOne = false;
            Object.keys(self.metrics[key]).forEach(function (subMetricKey) {
              if (subMetricKey.toLowerCase().indexOf(lowerQuery) !== -1) {
                filteredSubMetric[subMetricKey] = self.metrics[key][subMetricKey];
                atleastOne = true;
              }
            });
            if (atleastOne) {
              result[key] = filteredSubMetric;
            } else {
              result[key] = null;
            }
          });
          return result;
        }
        return self.metrics;
      });
    }

    $(document).ready(function () {
      ko.cleanNode(document.getElementById("metricsComponent"));
      ko.applyBindings(new MetricsViewModel(), document.getElementById('metricsComponent'));
    });
  })();
</script>

${layout.menubar(section='metrics')}

<div id="metricsComponent" class="container-fluid">
  <div class="card card-small margin-top-10">
    <div data-bind="dockable: { scrollable: ${ MAIN_SCROLLABLE }, jumpCorrection: 0,topSnap: '${ TOP_SNAP }', triggerAdjust: ${ is_embeddable and "0" or "106" }}">
    <!-- ko if: metrics -->
    <ul class="nav nav-pills">
      <li data-bind="css: { 'active': $root.selectedMetric() === 'All' }">
        <a href="javascript:void(0)" data-bind="text: 'All', click: function(){ $root.selectedMetric('All') }"></a>
      </li>
      <!-- ko foreach: metricsKeys -->
      <li data-bind="css: { 'active': $root.selectedMetric() === $data }">
        <a href="javascript:void(0)" data-bind="text: $data, click: function(){ $root.selectedMetric($data) }"></a>
      </li>
      <!-- /ko -->
    </ul>
    <!-- /ko -->
    <input type="text" data-bind="clearable: metricsFilter, valueUpdate: 'afterkeydown'"
        class="input-xlarge pull-right margin-bottom-10" placeholder="${_('Filter metrics...')}">
    </div>
    <div class="margin-top-10">
      <div data-bind="foreach: {data: Object.keys($root.filteredMetrics()).sort(), as: '_masterkey'}">
       <!-- ko if: ($root.selectedMetric() === 'All' && $root.filteredMetrics()[_masterkey]) || $root.selectedMetric() === _masterkey-->
       <h4 data-bind="text: _masterkey"></h4>
       <table class="table table-condensed">
         <thead>
           <tr>
            <th width="30%">${ _('Name') }</th>
            <th>${ _('Value') }</th>
           </tr>
         </thead>
         <!-- ko if: $root.filteredMetrics()[_masterkey] -->
         <tbody data-bind="foreach: {'data': Object.keys($root.filteredMetrics()[_masterkey])}">
           <tr>
            <td data-bind="text: $data"></td>
            <td data-bind="text: $root.filteredMetrics()[_masterkey][$data]"></td>
           </tr>
         </tbody>
         <!-- /ko -->
         <!-- ko ifnot: $root.filteredMetrics()[_masterkey] -->
         <tfoot>
           <tr>
            <td colspan="2">${ _('There are no metrics matching your filter') }</td>
           </tr>
           </tfoot>
         <!-- /ko -->
        </table>
        <!-- /ko -->
      </div>
  </div>
 </div>
</div>


%if not is_embeddable:
${ commonfooter(request, messages) | n,unicode }
%endif
