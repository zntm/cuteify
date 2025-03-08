function cuteify_get_colour(_string, _asset_prefix = "")
{
    var _emote_data = global.emote_data;
    
    static __data = function(_text, _type = CUTEIFY_TYPE.STRING)
    {
        return [ _text, _type ];
    }
    
    var _data = [[]];
    
    var _index  = 0;
    var _index2 = 0;
    
    var _string_part = "";
    var _string_length = string_length(_string);
    
    for (var i = 1; i <= _string_length; ++i)
    {
        var _char = string_char_at(_string, i);
        
        if (_char == CUTEIFY_BRACKET_OPEN)
        {
            var _char_back  = string_char_at(_string, i - 1);
            var _char_front = string_char_at(_string, i + 1);
            
            if (i == _string_length) || ((((_char_back != CUTEIFY_BRACKET_OPEN) || (_char_back != CUTEIFY_BRACKET_CLOSE)) && ((_char_front != CUTEIFY_BRACKET_OPEN) || (_char_front != CUTEIFY_BRACKET_CLOSE))))
            {
                _string_part += CUTEIFY_BRACKET_OPEN;
            }
            
            if (string_length(_string_part) > 0)
            {
                _data[@ _index2][@ _index++] = __data(_string_part);
            }
            else if (i == 1) || (_char_front != CUTEIFY_BRACKET_CLOSE) || (_char_back == CUTEIFY_BRACKET_OPEN) || (_char_back == CUTEIFY_BRACKET_CLOSE)
            {
                _data[@ _index2][@ _index++] = __data(CUTEIFY_BRACKET_OPEN);
            }
            
            _string_part = "";
            
            continue;
        }
        
        if (_char == "\n")
        {
            if (string_length(_string_part) > 0)
            {
                _data[@ _index2][@ _index++] = __data(_string_part);
            }
            
            _index = 0;
            
            _string_part = "";
            
            continue;
        }
        
        if (_char == CUTEIFY_BRACKET_CLOSE) && (_index >= 1) && (string_ends_with(_data[_index2][_index - 1][0], CUTEIFY_BRACKET_OPEN))
        {
            if (string_length(_string_part) > 0)
            {
                var _type = CUTEIFY_TYPE.STRING;
                
                var _string_colour = hex_parse(_string_part, false);
                
                if (_string_colour != undefined)
                {
                    _string_part = _string_colour;
                    _type = CUTEIFY_TYPE.COLOUR;
                }
                
                if (_index > 0) && (_type != CUTEIFY_TYPE.STRING)
                {
                    var _ = _data[_index2][_index - 1][0];
                    
                    if (string_ends_with(_, CUTEIFY_BRACKET_OPEN))
                    {
                        _data[@ _index2][@ _index - 1][@ 0] = string_delete(_, string_length(_), 1);
                    }
                }
                
                _data[@ _index2][@ _index++] = __data(_string_part, _type);
            }
            else
            {
                _data[@ _index2][@ _index++] = __data(CUTEIFY_BRACKET_CLOSE);
            }
            
            _string_part = "";
            
            continue;
        }
        
        _string_part += _char;
    }
    
    if (string_length(_string_part) > 0)
    {
        _data[@ _index2][@ _index++] = __data(_string_part);
    }
    
    var _boolean = 0;
    
    var _colour = draw_get_colour();
    
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
            
            if (_type == CUTEIFY_TYPE.COLOUR)
            {
                _colour = _text;
            }
        }
    }
    
    return _colour;
}