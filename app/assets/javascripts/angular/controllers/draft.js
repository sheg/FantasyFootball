(function() {

  var app = angular.module('drafts', []);

  app.factory('Players', function() {
    return [
      {
        'first_name': 'Eli',
        'last_name': 'Manning',
        'position': 'QB',
        'team': 'NYG'
      },
      {
        'first_name': 'Alex',
        'last_name': 'Smith',
        'position': 'QB',
        'team': 'KC'
      },
      {
        'first_name': 'Frank',
        'last_name': 'Gore',
        'position': 'RB',
        'team': 'SF'
      }
    ];
  });

  app.controller('DraftPlayersController', ['$scope', 'Players', function($scope, players) {
    $scope.players = players;
  }]);
})();



//app.controller('LeadsController', ['$http', '$scope', function($http, $scope) {
//  $scope.lead = {};
//
//  $http.get("/v1/leads").success(function(data) {
//    $scope.leads = data;
//  });
//
//  $scope.addLead = function() {
//    $http.post('/v1/leads', { name: $scope.lead.name, email: $scope.lead.email }).success(function(data) {
//      $scope.leads.push(data);
//      $scope.lead = {};
//    });
//  };
//
//  $scope.deleteLead = function(leadIndex) {
//    var lead = $scope.leads[leadIndex];
//    var _confirm = confirm("Are you sure you want to delete " + lead.name + "?");
//    if(_confirm) {
//      $http.delete("/v1/leads/" + lead.id).success(function() {
//        $scope.leads.splice(leadIndex, 1);
//      });
//    }
//  };
//
//  $scope.clearLead = function() {
//    $scope.lead = {};
//    $('#new-lead-name').val('');
//    $('#new-lead-email').val('');
//    $scope.addLeadForm.$setPristine();
//  };
//}]);
