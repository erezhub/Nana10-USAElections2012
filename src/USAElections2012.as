package
{
	import cinabu.HebrewTextHandling;
	
	import com.adobe.serialization.json.JSON;
	import com.data.Candidate;
	import com.data.State;
	import com.fxpn.util.ContextMenuCreator;
	import com.fxpn.util.DisplayUtils;
	import com.fxpn.util.MathUtils;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.utils.Timer;
	
	import gs.TweenLite;
	
	import org.osmf.events.TimeEvent;
	
	import resources.USAElectionsMap;
		
	[SWF (backgroundColor=0xffffff, width=780, height=460)]
	public class USAElections2012 extends Sprite
	{
		private const OBAMA:String = "אובמה";
		private const ROMNEY:String = "רומני";
		private const TOTAL_ELECTORS:int = 538;
		private const DEMOCTRATS:int = 0x0076B6;
		private const REPUBLICANS:int = 0xC40002;
		
		private var urlRequest:URLRequest;
		private var urlLoader:URLLoader;
		private var loaderTimer:Timer;
		private var wsURL:String;
		
		private var electionsData:Object;
		private var candidates:Array;
		private var states:Array;
		
		private var map:USAElectionsMap;
		private var obama_fmt:TextFormat;
		private var republican_fmt:TextFormat;
		
		public function USAElections2012()
		{			
			Security.allowDomain("f-dev.nanafiles.co.il","f.nanafiles.co.il");
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);	
			obama_fmt = new TextFormat("arial",14,DEMOCTRATS,true);
			republican_fmt = new TextFormat("arial",14,REPUBLICANS,true);
						
			contextMenu = ContextMenuCreator.setContextMenu("Nana10 (c) 2012 V8");
		}
		
		private function onAddedToStage(event:Event):void
		{
			map = new USAElectionsMap();
			addChild(map);
			with (map.totalVotes)
			{
				percentage_txt.text = 0;
				obamaElectors_txt.text = "('קלא " + 0;
				romneyElectors_txt.text = "('קלא " + 0;
				noneElectors_txt.text = "('קלא " + (TOTAL_ELECTORS);
			}
			map.errorMessage.visible = map.toolTip.visible = false
			map.toolTip.alpha = 0;
			
			var url:String = stage.loaderInfo.url;
			wsURL = "http://specials" + (url.indexOf("-dev") == -1 && url.indexOf("workspace") == -1 ? "" : "-dev") + ".nana10.co.il/USAElections2012/Action.ashx?r=";
			urlRequest = new URLRequest(wsURL + MathUtils.randomInteger(1000,100000));
			urlLoader = new URLLoader(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE,onDataLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onDataError);
			
			loadData();
			
			loaderTimer = new Timer(60*1000);
			loaderTimer.addEventListener(TimerEvent.TIMER,loadData);
			loaderTimer.start();
		}
		
		private function loadData(event:TimerEvent = null):void
		{
			urlRequest.url = wsURL + MathUtils.randomInteger(1000,10000);
			urlLoader.load(urlRequest);	
		}
		
		private function onDataLoaded(event:Event):void
		{
			var data:Object = JSON.decode(event.target.data);
			if (data.ActionSucceeded)
			{
				candidates = [];
				states = [];
				electionsData = data.Details;
				var obama:Candidate;
				var romney:Candidate;
				for each (var candidateObj:Object in electionsData.CandidateList)
				{
					var candidate:Candidate = new Candidate(candidateObj.CandidateID,candidateObj.CandidateName); 
					candidates.push(candidate);
					if (candidate.name == OBAMA) obama = candidate;
					if (candidate.name == ROMNEY) romney = candidate;
				}
				candidates.sortOn("id");
				for each (var stateObj:Object in electionsData.StatesList)
				{
					var state:State = new State(stateObj.StateID,stateObj.StateName,stateObj.StateAbbrevation,stateObj.StateWinner,stateObj.StateFormerWinner,stateObj.StateElectors); 
					states.push(state);
					candidates[state.winner].totalVotes+= state.electors;
					var state_mc:MovieClip = map[state.abbrevation + "_mc"];
					state_mc.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
					state_mc.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
					state_mc.stateData = state;
					if (candidates[state.winner].name == OBAMA || candidates[state.winner].name == ROMNEY) 
						DisplayUtils.setTintColor(state_mc.bg,candidates[state.winner].name == OBAMA ? DEMOCTRATS : REPUBLICANS);
					else
						DisplayUtils.setTintColor(state_mc.bg,0xD3D3D3);
				}
				with (map.totalVotes)
				{
					percentage_txt.text = Math.min(Math.max(electionsData.PercentageData.percentage,0),100);
					obamaElectors_txt.text = "('קלא " + obama.totalVotes;
					romneyElectors_txt.text = "('קלא " + romney.totalVotes;
					noneElectors_txt.text = "('קלא " + (TOTAL_ELECTORS - obama.totalVotes - romney.totalVotes);
				}
				map.toolTip.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
				map.errorMessage.visible = false;
			}
			else
			{
				displayError();
			}
		}
		
		private function onDataError(event:IOErrorEvent):void
		{
			displayError();
		}
		
		private function displayError():void
		{
			map.errorMessage.visible = true;
			with (map.totalVotes)
			{
				percentage_txt.text = "0";
				obamaElectors_txt.text = "('קלא " + 0;
				romneyElectors_txt.text = "('קלא " + 0;
				noneElectors_txt.text = "('קלא " + (TOTAL_ELECTORS);
			}
		}
		
		private function onRollOver(event:MouseEvent):void
		{
			TweenLite.to(map.toolTip,0.3,{alpha: 1});
			map.toolTip.visible = true;
			states = [];
			for each (var stateObj:Object in electionsData.StatesList)
			{
				var state:State = new State(stateObj.StateID,stateObj.StateName,stateObj.StateAbbrevation,stateObj.StateWinner,stateObj.StateFormerWinner,stateObj.StateElectors);
				var state_mc:MovieClip = map[state.abbrevation + "_mc"];
				if (candidates[state.winner].name == OBAMA || candidates[state.winner].name == ROMNEY) 
					DisplayUtils.setTintColor(state_mc.bg,candidates[state.winner].name == OBAMA ? DEMOCTRATS : REPUBLICANS);
				else
					DisplayUtils.setTintColor(state_mc.bg,0xD3D3D3);
			}
			var targetState:State = event.target.stateData;
			with (map.toolTip)
			{
				visible = true;
				state_txt.text = targetState.name;
				electors_txt.text = targetState.electors;
				if (candidates[targetState.winner].name == OBAMA || candidates[targetState.winner].name == ROMNEY)
				{
					winner_txt.text = "ניצחון ל" + candidates[targetState.winner].name;
					setFMT(winner_txt,targetState.winner);
				}
				else
				{
					winner_txt.text = "לא הוכרע";
				}
				formerWinner_txt.text = "ניצחון ל" + candidates[targetState.formerWinner].name;
				setFMT(formerWinner_txt,targetState.formerWinner);
				
				x = event.target.x + event.target.width;
				if (x + width > stage.stageWidth) x = event.target.x - width;
				y = event.target.y;
				if (y + height > stage.stageHeight) y = stage.stageHeight - height - 20;
			}
			
			
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			if (event.relatedObject == map.toolTip) return;
			TweenLite.to(map.toolTip,0.3,{alpha: 0, onComplete: onFinishedTween});
			//map.toolTip.visible = false;
		}
		
		private function onFinishedTween():void
		{
			map.toolTip.visible = false;
		}
		
		private function setFMT(tf:TextField,candidateID:int):void
		{
			if (candidates[candidateID].name == OBAMA)
				tf.setTextFormat(obama_fmt);
				//tf.defaultTextFormat = obama_fmt;
			else
				tf.setTextFormat(republican_fmt);
				//tf.defaultTextFormat = republican_fmt;
		}
	}
}