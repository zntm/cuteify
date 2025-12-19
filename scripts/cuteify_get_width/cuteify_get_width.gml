/// @func cuteify_get_width(_string, _asset_prefix)
/// @desc Gets the width of a cuteify-formatted string
/// @param {String} _string The input string with formatting tags
/// @param {String} _asset_prefix Prefix for asset lookups
/// @returns {Real} Width in pixels
function cuteify_get_width(_string, _asset_prefix = "")
{
    var _current_font = draw_get_font();
    
    var _parsed = cuteify_parse(_string, _asset_prefix);
    var _data = _parsed.data;
    var _index2 = _parsed.line_count;
    
    var _width = 0;
    var _boolean = 0;
    
    for (var i = 0; i <= _index2; ++i)
    {
        var _xoffset = 0;
        
        var _data_current = _data[i];
        var _length = array_length(_data_current);
        
        for (var j = 0; j < _length; ++j)
        {
            var _ = _data_current[j];
            
            var _text = _[0];
            var _type = _[1];
            
            if (_type == CUTEIFY_TYPE.COLOUR) continue;
            
            if (_type == CUTEIFY_TYPE.SPRITE)
            {
                _xoffset += sprite_get_width(_text);
                
                continue;
            }
            
            if (j != _length - 1) && (_text == CUTEIFY_BRACKET_OPEN) && (_data_current[j + 1][1] != CUTEIFY_TYPE.STRING) continue;
            
            if (_type == CUTEIFY_TYPE.OBSTRUCT)
            {
                _boolean ^= CUTEIFY_BOOLEAN.OBSTRUCT;
                
                continue;
            }
            
            if (_type == CUTEIFY_TYPE.UNDERLINE)
            {
                _boolean ^= CUTEIFY_BOOLEAN.UNDERLINE;
                
                continue;
            }
            
            var _text_length = string_length(_text);
            
            if (_boolean & CUTEIFY_BOOLEAN.OBSTRUCT)
            {
                for (var l = 1; l <= _text_length; ++l)
                {
                    var _char = chr(irandom_range(32, 127));
                    
                    _xoffset += string_width(_char);
                }
                
                continue;
            }
            
            if (_text_length <= 0) continue;
            
            _xoffset += string_width(_text);
        }
        
        _width = max(_width, _xoffset);
    }
    
    draw_set_font(_current_font);
    
    return _width;
}