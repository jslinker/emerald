TextBox = {}

TextBox.text = nil
TextBox.rows = nil
TextBox.row = 1
-- TextBox.cursor = 1

function TextBox.update(self)

end

function TextBox.setText(self, text)
    if text == nil then 
        self.text = nil
        self.rows = nil
        self.row = 1
        return 
    end

    printh(text)

    local width = 15
    self.text = text
    local lineCount = ceil(#text/width)
    self.lines = {}
    for i=1,#text,width do
        local subText = sub(text, i, i + width)
        add(self.lines, subText)
        printh(subText)
    end
end

-- function _init()
--     tbx_init()
--     sample_text="hello, this is a basic function for printing text letter by letter with text wrapping. it works pretty well."
--     sample_text2="it is a little janky and not very optimized, but it is good enough for my needs and it clocks in just under 300 tokens."
--    end
    
--    function _update()
--     tbx_update()
--     if (btnp (4)) textbox(sample_text,nil,nil,12)
--     if (btnp(5))  textbox(sample_text2,nil,nil,12)
--    end
   
--    function _draw()
--     cls()
--     if (#tbx_lines>0) tbx_draw()
--    end
--    -----
   
--    function tbx_init()
--    tbx_counter=1
--    tbx_width=25 --characters not pixels
--    tbx_lines={}
--    tbx_cur_line=1
--    tbx_com_line=0
--    tbx_text=nil
--    tbx_x=nil
--    tbx_y=nil
--    end
   
   
--    function tbx_update()
--     if tbx_text!=nil then 
--     local first=nil
--     local last=nil
--     local rows=flr(#tbx_text/tbx_width)+2
    
--     --split text into lines
--     for i=1,rows do
--      first =first or 1+i*tbx_width-tbx_width
--      last = last or i*tbx_width
      
--      --cut off incomplete words
--      if sub(tbx_text,last+1,last+1)!="" or sub(tbx_text,last,last)!=" " and sub(tbx_text,last+1,last+1)!=" " then
--       for j=1,tbx_width/3 do
--        if sub(tbx_text,last-j,last-j)==" " and i<rows then
--         last=last-j
--         break
--        end
--       end
--      end
     
--      --create line
--      --if first char is a space, remove the space
--      if sub(tbx_text,first,first)==" " then
--       tbx_lines[i]=sub(tbx_text,first+1,last)
--      else
--       tbx_lines[i]=sub(tbx_text,first,last)
--      end
--       first=last
--       last=last+tbx_width
--     end
    
--     --lines are now made
    
    
--     --change lines after printing
--     if tbx_counter%tbx_width==0 and tbx_cur_line<#tbx_lines then
--      tbx_com_line+=1
--      tbx_cur_line+=1
--      tbx_counter=1  
--     end
--     --update text counter
--     tbx_counter+=1
--     if (sub(tbx_text,tbx_counter,tbx_counter)=="") tbx_counter+=1
--     end
--    end
   
   
--    function tbx_draw()
--     if #tbx_lines>0 then
--      --print current line one char at a time
--      print(sub(tbx_lines[tbx_cur_line],1,tbx_counter),tbx_x,tbx_y+tbx_cur_line*6-6,tbx_col)
   
    
--      --print complete lines
--      for i=0,tbx_com_line do
--       if i>0 then
--        print(tbx_lines[i],tbx_x,tbx_y+i*6-6,tbx_col)
--       end
--      end
--     end 
--    end
   
   
--    function textbox(text,x,y,col)
--     tbx_init()
--     tbx_x=x or 4
--     tbx_y=y or 4
--     tbx_col=col or 7
--     tbx_text=text
--    end