var stargit=(function(){
	var flash;
	var githubNodesObj = {};
	var githubEdgesObj = {};
	var graphAttributes = {};
	
	function setFlash(){
		if (navigator.appName.indexOf("Microsoft") != -1) {
			flash = window["SiGMa"];
		} else {
			flash = document["SiGMa"];
		}
		
		if(!flash){
			return false;
		}else{
			return true;
		}
	}
	
	function setLegend(attName,attribute){
		// First, let's remove all "legend_element" elements:
		$("#legend>*").remove();
		
		// Then, let's add the new legend elements:
		var legTitle = document.createElement("div");
		legTitle.id = "legend_title";
		
		$("#legend").append(legTitle);
		$("#legend_title").append("Nodes color: ");
		
		var fieldB = document.createElement("strong");
		fieldB.style.fontSize = "12px";
		fieldB.innerHTML = (attribute["label"]?attribute["label"]:attName);
		$("#legend_title").append(fieldB);
		
		var legElements = document.createElement("div");
		legElements.id = "legend_elements";
		
		$("#legend").append(legElements);
		
		if(attribute["type"]=="Num"){
			var grad = document.createElement("div");
			
			grad.style.backgroundImage = 
				"-webkit-gradient("+
	    	"    linear,"+
	    	"    left top,"+
	    	"    right top,"+
	    	"    color-stop(0, "+attribute["colorMax"].replace("0x","#")+"),"+
	    	"    color-stop(1, "+attribute["colorMin"].replace("0x","#")+"))";
    	
    	grad.style.backgroundImage = 
	    	"-moz-linear-gradient("+
	    	"    left center,"+
	    	"    "+attribute["colorMax"].replace("0x","#")+" 0%,"+
	    	"    "+attribute["colorMin"].replace("0x","#")+" 100%)";
	    
			$("#legend_elements").append("<br/>");
			
	    grad.style.height = "20px";
	    grad.style.width = "80%";
	    grad.style.marginLeft = "10%";
    	
			$("#legend_elements").append(grad);
			
			var lowest = document.createElement("div");
			lowest.style.paddingTop = "5px";
			lowest.style.paddingLeft = "5px";
			lowest.style.float = "left";
			lowest.style.styleFloat = "left";
			lowest.style.cssFloat = "left";
			lowest.style.display = "inline";
			lowest.innerHTML = "(lowest values)";
			$("#legend_elements").append(lowest);
			
			var highest = document.createElement("div");
			highest.style.paddingTop = "5px";
			highest.style.paddingRight = "5px";
			highest.style.float = "right";
			highest.style.styleFloat = "right";
			highest.style.cssFloat = "right";
			highest.style.display = "inline";
			highest.innerHTML = "(highest values)";
			$("#legend_elements").append(highest);
			
		}else if(attribute["type"]=="Str"){
			var l = attribute["values"].length;
			
			for(var val in attribute["values"]){
				var le = document.createElement("div");
				le.id = "value_"+val;
				le.style.display = "inline";
				$("#legend_elements").append(le);
				
				var bg = document.createElement("div");
				bg.style.width = "13px";
				bg.style.height = "13px";
				bg.style.marginLeft = "12px";
				bg.style.marginTop = "12px";
				bg.style.float = "left";
				bg.style.styleFloat = "left";
				bg.style.cssFloat = "left";
				bg.style.backgroundColor = attribute["values"][val].replace("0x","#");
				$("#value_"+val).append(bg);
				
				var ti = document.createElement("div");
				ti.innerHTML = val;
				ti.style.paddingLeft = "3px";
				ti.style.marginTop = "12px";
				ti.style.float = "left";
				ti.style.styleFloat = "left";
				ti.style.cssFloat = "left";
				$("#value_"+val).append(ti);
			}
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
	  			if(document.getElementById("query_input").value) document.getElementById("query_input").value = user;
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
	  
	  if(document.getElementById("query_color").value) flash.setColor(document.getElementById("query_color").value,graphAttributes);
	  if(document.getElementById("query_size").value) flash.setSize(document.getElementById("query_size").value);
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
		
		var nodes_color = document.getElementById("query_color");
		var nodes_size = document.getElementById("query_size");
		
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
		
		if(graphAttributes){
			console.debug(colorAtts[0]);
			console.debug(graphAttributes[colorAtts[0]]);
			setLegend(colorAtts[0]["label"],colorAtts[0]);
		}
	}
	
	// PUBLIC FUNCTIONS:
	return {
		loadUser: function(name){
			getGithubGraph(name);
		},
		
		setSize: function(e){
			if(!setFlash()) return;
			console.debug(e.target.value);
			flash.setSize(e.target.value);
		},
		
		setColor: function(e){
			if(!setFlash()) return;
			console.debug(e.target.value);
			
			setLegend(e.target.value,graphAttributes[e.target.value]);
			
			flash.setColor(e.target.value,graphAttributes);
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
		},
		
		getGraphAttributes: function(){
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
		},

		onClickNodes: function(nodesArray){
		  if(nodesArray.length){
		    query = nodesArray[0];
		    
		    getGithubGraph(query);
		    document.getElementById("query_input").value = query;
			}
		},
		
		onOverNodes: function(nodesArray){
			for(var i=0;i<nodesArray.length;i++){
				console.debug("node: "+nodesArray[i]);
			}
		}
	};
})();