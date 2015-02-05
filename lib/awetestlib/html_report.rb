require 'json'

module Awetestlib
  # Report generator for Awetestlib.
  class HtmlReport

    # Initialize the report class
    # @private
    def initialize(report_name)
      @reportname     = report_name
      @reportContent1 = ''
      @reportContent2 = ''
    end

    # Create a report
    # @private
    def create_report(reportName)
      # Get current time
      t = Time.now

      @col_1_p        = '65%'
      @col_2_p        = '25%'
      @col_3_p        = '10%'

      # Create the report name
      rpt_time        = "#{t.strftime("%Y%m%d_%H%M%S")}"
      rpt_nice_time   = "#{t.strftime("%m/%d/%Y @ %H:%M:%S")}"
      rpt_file_name   = "#{reportName}_#{rpt_time}.html"
      @rpt_json_file   = "#{reportName}_#{rpt_time}.json"
      # Create the HTML & Json report
      rpt_file        = File.open(rpt_file_name, 'w')
      rpt_json        = File.open(@rpt_json_file, 'w')

      # Format the header of the HTML report
      @reportContent1 = '<html>
        <head>
        <meta content=text/html; charset=ISO-8859-1 http-equiv=content-type>
        <title>Awetestlib Test Run</title>
        <style type=text/css>
        .title { font-family: verdana; font-size: 30px;  font-weight: bold; align: left; color: #000000;}
        .bold_text { font-family: verdana; font-size: 11px;  font-weight: bold;}
        .bold_large_text { font-family: verdana; font-size: 12px;  font-weight: bold;}
        .normal_text { font-family: verdana; font-size: 11px; font-weight: normal;}
        .center_text { font-family: verdana; font-size: 11px; font-weight: normal; text-align: center;}
        .small_text { font-family: verdana; font-size: 9px;  font-weight: normal; }
        .border { border: 1px solid #000000;}
        .mark_testlevel_left { border-top: 1px solid #858585; border-left: 1px solid #858585;background-color:#E2F4FE;}
        .mark_testlevel_middle { border-top: 1px solid #858585; background-color:#E2F4FE;}
        .mark_testlevel_right { border-top: 1px solid #858585; border-right: 1px solid #858585;background-color:#E2F4FE;}
        .border_left { border-top: 1px solid #858585; border-left: 1px solid #858585; border-right: 1px solid #858585;}
        .border_middle { border-top: 1px solid #858585; border-right: 1px solid #858585;}
        .border_right { border-top: 1px solid #858585; border-right: 1px solid #858585;}
        .result_ok { font-family: verdana; font-size: 11px;  font-weight: bold; text-align: center; color: green;}
        .result_nok { font-family: verdana; font-size: 11px;  font-weight: bold; text-align: center; color: red;}
        .overall_ok { font-family: verdana; font-size: 11px;  font-weight: bold; text-align: left; color: green;}
        .overall_nok { font-family: verdana; font-size: 11px;  font-weight: bold; text-align: left; color: red;}
        .bborder_left { border-top: 1px solid #858585; border-left: 1px solid #858585; border-bottom: 1px solid #858585; background-color:#858585;font-family: verdana; font-size: 12px;  font-weight: bold; text-align: center; color: white;}
        .bborder_right { border-right: 1px solid #858585; background-color:#858585;font-family: verdana; font-size: 12px;  font-weight: bold; text-align: center; color: white;}
        </style>
        </head>
        <body>
        <br>
        <center>
        <table width=auto border=0 cellpadding=2 cellspacing=2>
        <tbody>
        <tr>
        <td>
        <table width=90% border=0 cellpadding=2 cellspacing=2>
        <tbody>
        <tr>
        <td style=width: 150px;>&nbsp;</td>
        <td align=left><img src="https://raw.github.com/3qilabs/awetestlib/develop/images/logo.png"></img></td>
        <td align=right><p class=title>Test Report</p></td>
        </tr>
        </tbody>
        </table>
        <br>
        <hr width=100% class=border size=1px>
        <center>
        <table border=0 width=100% cellpadding=2 cellspacing=2>
        <tbody>
        <tr>
        <td width=10%><p class=normal_text></p></td>
        <td width=20%><p class=bold_text>Script</p></td>
        <td width=5%><p class=bold_text>:</p></td>
        <td width=65%><p class=normal_text>' + @reportname.capitalize + '</p></td>
        </tr>
        <tr>
        <td width=10%><p class=normal_text></p></td>
        <td width=20%><p class=bold_text>Test Execution</p></td>
        <td width=5%><p class=bold_text>:</p></td>
        <td width=65%><p class=normal_text>' + rpt_nice_time + '</p></td>
        </tr>
        <tr>'

      @reportContent2 = '</tr>
        </tbody>
        </table>
        </center>
        <br>
        <center>
        <table width=100% cellpadding=2 cellspacing=0>
        <tbody>
        <tr>
        <td class=bborder_left width=' + @col_1_p + '><p>Test Step</p></td>
        <td class=bborder_left width=' + @col_2_p + '><p>Location</p></td>
        <td class=bborder_left width=' + @col_3_p + '><p>Result</p></td>
        </tr>' + "\n"

      @jsonContent={}
      @jsonContent["report_type"]="Awetestlib Report"
      @jsonContent["Data_order"]="message, location, result, level, Time.now"
      @line_no = 1
      # Close the report
      rpt_file.close
      rpt_json.close

      return rpt_file_name
    end

    # Add a row to the report
    # @private
    def add_to_report(message, location, result, level = 1)
      # Format the body of the HTML report

      left_class   = 'border_left'
      right_class  = 'border_right'
      pgph_class   = 'normal_text'
      loc_class    = 'center_text'
      rslt_class   = 'result_ok'
      middle_class = 'border_middle'

      rslt_class = 'result_nok' if result == "FAILED"
      case result
        when 'FAILED'
          rslt_class = 'result_nok'
        when 'PASSED'
          rslt_class = 'result_ok'
        else
          if level
            if level >= 1
              pgph_class   = 'bold_large_text'
              left_class   = 'mark_testlevel_left'
              middle_class = 'mark_testlevel_middle'
              right_class  = 'mark_testlevel_right'
            end
          end
      end

      row = '<tr>
        <td class=' + left_class + ' width=' + @col_1_p + '><p class=' + pgph_class + '>' + message + '</p></td>
        <td class=' + middle_class + ' width=' + @col_2_p + '><p class=' + loc_class + '>' + location + '</p></td>
        <td class=' + right_class + ' width=' + @col_3_p + '><p class=' + rslt_class + '>' + result + '</p></td>
        </tr>'

      @reportContent2 += row + "\n"
      @jsonContent["line_no_#{@line_no}"]=[message, location, result, level, Time.now]
      @line_no +=1

      #if (result == 'PASSED')
      #  @reportContent2 = @reportContent2 + '<tr>C'
      #  @reportContent2 = @reportContent2 + '<td class=border_right width=20%><p class=result_ok>' + result + '</p></td>'
      #elsif (result == 'FAILED')
      #  @reportContent2 = @reportContent2 + '<tr><td class=border_left width=80%><p class=normal_text>' + step + '</p></td>'
      #  @reportContent2 = @reportContent2 + '<td class=border_right width=20%><p class=result_nok>' + result + '</p></td>'
      #elsif level < 1
      #  @reportContent2 = @reportContent2 + '<tr><td class=border_left width=80%><p class=normal_text>' + step + '</p></td>'
      #  @reportContent2 = @reportContent2 + '<td class=border_right width=20%><p class=result_ok>' + result + '</p></td>'
      #else
      #  @reportContent2 = @reportContent2 + '<tr><td class=mark_testlevel_left width=80%><p class=bold_large_text>' + step + '</p></td>'
      #  @reportContent2 = @reportContent2 + '<td class=mark_testlevel_right width=20%><p class=result_ok>' + result + '</p></td>'
      #end

    end

    # Close the report HTML
    # @private
    def finish_report(reportName)
      # Open the HTML report
      rpt_file = File.open(reportName, 'a')
      rpt_json = File.open(@rpt_json_file, 'a')
      @reportContent2 = @reportContent2 + '<tr>
      <td class=bborder_left width=' + @col_1_p + '><p>&nbsp;</p></td>
      <td class=bborder_left width=' + @col_2_p + '><p>&nbsp;</p></td>
      <td class=bborder_left width=' + @col_3_p + '><p>&nbsp;</p></td>
      </tr>
      </table>'

      rpt_file.puts(@reportContent1)

      rpt_file.puts(@reportContent2)
      rpt_json.puts(@jsonContent.to_json)
      # Close the report
      rpt_file.close
      rpt_json.close
    end
  end
end
