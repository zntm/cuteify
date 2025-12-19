/// @func cuteify_get_height(_string, _asset_prefix)
/// @desc Gets the height of a cuteify-formatted string
/// @param {String} _string The input string with formatting tags
/// @param {String} _asset_prefix Prefix for asset lookups
/// @returns {Real} Height in pixels
function cuteify_get_height(_string, _asset_prefix = "")
{
    var _current_font = draw_get_font();
    var _string_height = ((_current_font == -1) ? 16 : string_height("I"));
    
    var _parsed = cuteify_parse(_string, _asset_prefix);
    var _data = _parsed.data;
    var _index2 = _parsed.line_count;
    
    var _height = 0;
    
    for (var i = 0; i <= _index2; ++i)
    {
        var _data_current = _data[i];
        var _length = array_length(_data_current);
        
        var _line_height = _string_height;
        
        for (var j = 0; j < _length; ++j)
        {
            var _ = _data_current[j];
            
            var _text = _[0];
            var _type = _[1];
            
            if (_type == CUTEIFY_TYPE.SPRITE)
            {
                _line_height = max(_line_height, sprite_get_height(_text));
                
                continue;
            }
            
            if (_type == CUTEIFY_TYPE.FONT)
            {
                draw_set_font(_text);
                
                _line_height = max(_line_height, string_height("I"));
                
                continue;
            }
        }
        
        _height += _line_height;
    }
    
    draw_set_font(_current_font);
    
    return _height;
}