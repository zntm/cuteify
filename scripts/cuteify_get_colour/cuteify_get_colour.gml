/// @func cuteify_get_colour(_string, _asset_prefix)
/// @desc Gets the last colour specified in a cuteify-formatted string
/// @param {String} _string The input string with formatting tags
/// @param {String} _asset_prefix Prefix for asset lookups
/// @returns {Constant.Color|Real} The last colour found, or current draw colour if none
function cuteify_get_colour(_string, _asset_prefix = "")
{
    var _parsed = cuteify_parse(_string, _asset_prefix);
    var _data = _parsed.data;
    var _index2 = _parsed.line_count;
    
    var _colour = draw_get_colour();
    
    for (var i = 0; i <= _index2; ++i)
    {
        var _data_current = _data[i];
        var _length = array_length(_data_current);
        
        for (var j = 0; j < _length; ++j)
        {
            var _ = _data_current[j];
            
            var _text = _[0];
            var _type = _[1];
            
            if (_type == CUTEIFY_TYPE.COLOUR)
            {
                _colour = _text;
            }
        }
    }
    
    return _colour;
}