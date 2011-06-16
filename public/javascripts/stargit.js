var stargit=(function(){
	// Functions:
	var flash;
	var githubNodesObj = {};
	var githubEdgesObj = {};
	var graphAttributes = {};
	
	function setFlash(){
		flash = $('#SiGMa')[0];
		
		if(!flash){
			return false;
		}else{
			return true;
		}
	}
	
	// This function refreshes the graph from the login of
	// a user:
	function getGithubGraph(user){
	  url = "/graph/local/"+user;
	  
	  $.ajax({
	    url: url,
	    dataType: 'json',
	    success:
	      function(json){
	        resetGraph(json);
	      }
	  });
	}
	
	// This function gets the graph attributes to refresh
	// the different comboboxes:
	function getGraphAttributes(){
	  url = "/graph/attributes";
	  
	  $.ajax({
	    url: url,
	    dataType: 'json',
	    success:
	      function(json){
	        graphAttributes = (json && json["attributes"]) ? json["attributes"] : {};
	        setComboBoxes();
	      }
	  });
	}

	function resetGraph(graph){
		if(!setFlash()){
			return;
		}
		
	  flash.resetGraphPosition();
	
	  flash.killForceAtlas();
	  flash.deleteGraph();
	  flash.updateGraph(graph);
	  flash.initForceAtlas();
	  
	  if($("#query_color").value) flash.setColor($("#query_color").value,graphAttributes);
	  if($("#query_size").value) flash.setSize($("#query_size").value);
	}

	// This function updates the comboboxes:
	function setComboBoxes(){
		var colorAtts = [];
		var sizeAtts = [];
		
		for(var att in graphAttributes){
			graphAttributes[att]["id"] = att;
			
			if(graphAttributes[att]["type"]=="Num"){
				sizeAtts.push(graphAttributes[att]);
				colorAtts.push(graphAttributes[att]);
			}else{
				colorAtts.push(graphAttributes[att]);
			}
		}
		
		var nodes_color = $("#query_color");
		var nodes_size = $("#query_size");
		
		while(nodes_color.options.length) nodes_color.options.remove(0);
		while(nodes_size.options.length) nodes_size.options.remove(0);
		
		var i;
		var optn;
		
		var l=colorAtts.length;
		for(i=0;i<l;i++){
			optn = document.createElement("OPTION");
			optn.text = colorAtts[i]["label"] ? colorAtts[i]["label"] : colorAtts[i]["id"];
			optn.value = colorAtts[i]["id"];
			
			nodes_color.options.add(optn);
		}
		
		l=sizeAtts.length;
		for(i=0;i<l;i++){
			optn = document.createElement("OPTION");
			optn.text = sizeAtts[i]["label"] ? sizeAtts[i]["label"] : sizeAtts[i]["id"];
			optn.value = sizeAtts[i]["id"];
			
			nodes_size.options.add(optn)
		}
	}
	
	// PUBLIC FUNCTIONS:
	return {
		loadUser: function(name){
			getGithubGraph(name);
		},
		
		setSize: function(e){
			if(!setFlash()) return;
			flash.setSize(e.value);
		},
		
		setColor: function(e){
			if(!setFlash()) return;
			flash.setColor(e.value,graphAttributes);
		},
		
		toggleEdges: function(){
			if(!setFlash()) return;
			var areEdgesDisplayed = flash.getDisplayEdges();
			flash.setDisplayEdges(!areEdgesDisplayed);
			return !areEdgesDisplayed;
		},
		
		toggleLabels: function(){
			if(!setFlash()) return;
			var areLabelsDisplayed = flash.getDisplayLabels();
			flash.setDisplayLabels(!areLabelsDisplayed);
			return !areLabelsDisplayed;
		},
		
		toggleFishEye: function(){
			if(!setFlash()) return;
			var isFishEye = flash.hasFishEye();
			if(isFishEye){
				flash.deactivateFishEye();
			}else{
				flash.activateFishEye();
			}
			return !isFishEye;
		}
	};
})();