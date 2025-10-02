extends Object



static var _SHORT_STRING: String
static func get_short_string() -> String:
	if _SHORT_STRING:
		return _SHORT_STRING
	
	var version_info = Engine.get_version_info()
	
	_SHORT_STRING = str(version_info["major"]) + "." + str(version_info["minor"])
	
	if version_info["patch"]:
		_SHORT_STRING += "." + str(version_info["patch"])
	
	if version_info["status"] != "stable":
		_SHORT_STRING += "-" + version_info["status"]
	
	if version_info["build"] != "official":
		_SHORT_STRING += "." + version_info["build"] + " [" + version_info["hash"].substr(0, 9) + "]"
	
	return _SHORT_STRING
