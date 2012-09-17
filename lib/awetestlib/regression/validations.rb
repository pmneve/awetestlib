module Awetestlib
  module Regression
    # Contains methods to verify content, accessibility, or appearance of page elements.
    module Validations

      # @!group Core

      # Verify that element style attribute contains expected value in style +type+.
      # @param [Watir::Browser] browser A reference to the browser window or container element to be tested.
      # @param [Symbol] element The kind of element to click. Must be one of the elements recognized by Watir.
      #   Some common values are :link, :button, :image, :div, :span.
      # @param [Symbol] how The element attribute used to identify the specific element.
      #   Valid values depend on the kind of element.
      #   Common values: :text, :id, :title, :name, :class, :href (:link only)
      # @param [String, Regexp] what A string or a regular expression to be found in the *how* attribute that uniquely identifies the element.
      # @param [String] desc Contains a message or description intended to appear in the log and/or report output
      # @param [String] type The name of the style type (sub-attribute) where +expected+ is to be found.
      # @param [String] expected The value in +type+ expected.
      # @return [Boolean] True if the style type contains the expected value
      #
      def validate_style_value(browser, element, how, what, type, expected, desc = '')
        #TODO: works only with watir-webdriver
        msg = build_message("Expected Style #{type} value '#{expected}' in #{element} with #{how} = #{what}", desc)
        case element
          when :link
            actual = browser.link(how => what).style type
          when :button
            actual = browser.button(how => what).style type
          when :image
            actual = browser.image(how => what).style type
          when :span
            actual = browser.span(how => what).style type
          when :div
            actual = browser.div(how => what).style type
          else
            if browser.element(how => what).responds_to?("style")
              actual = browser.element(how => what).style type
            else
              failed_to_log("#{msg}: Element #{element} does not reponds to style command.")
            end
        end
        if expected == actual
          passed_to_log(msg)
          true
        else
          failed_to_log(msg)
        end
      rescue
        failed_to_log("Unable to verify that #{msg} '#{$!}'")
      end

      # @!todo Clarify and rename
      def arrays_match?(exp, act, dir, col, org = nil, desc = '')
        if exp == act
          passed_to_log("Click on #{dir} column '#{col}' produces expected sorted list. #{desc}")
          true
        else
          failed_to_log("Click on #{dir} column '#{col}' fails to produce expected sorted list. #{desc}")
          debug_to_log("Original order ['#{org.join("', '")}']") if org
          debug_to_log("Expected order ['#{exp.join("', '")}']")
          debug_to_log("  Actual order ['#{act.join("', '")}']")
        end
      end

      alias arrays_match arrays_match?

      # Verify that a DOM element is enabled.
      # @param [Watir::Browser] browser A reference to the browser window or container element to be tested.
      # @param [Symbol] element The kind of element to click. Must be one of the elements recognized by Watir.
      #   Some common values are :link, :button, :image, :div, :span.
      # @param [Symbol] how The element attribute used to identify the specific element.
      #   Valid values depend on the kind of element.
      #   Common values: :text, :id, :title, :name, :class, :href (:link only)
      # @param [String, Regexp] what A string or a regular expression to be found in the *how* attribute that uniquely identifies the element.
      # @param [String] desc Contains a message or description intended to appear in the log and/or report output
      # @return [Boolean] Returns true if the element is enabled.
      def enabled?(browser, element, how, what, desc = '')
        #TODO: handle identification of element with value as well as other attribute. see exists?
        msg = build_message("#{element.to_s.titlecase} by #{how}=>'#{what}' is enabled.}", desc)
        case element
          when :textfield, :textarea, :text_area, :text_field
            rtrn = browser.text_field(how, what).enabled? and not browser.text_field(how, what).readonly?
          when :select_list, :selectlist
            rtrn = browser.select_list(how, what).enabled?
          else
            rtrn = browser.element(how, what).enabled?
        end
        if rtrn
          passed_to_log("#{msg}")
          true
        else
          failed_to_log("#{msg}")
        end
        rtrn
      rescue
        failed_to_log("#Unable to verify that #{msg}': '#{$!}")
      end

      alias validate_enabled enabled?

      # Verify that a DOM element is disabled.
      # @param (see #enabled?)
      # @return [Boolean] Returns true if the element is disabled.
      def disabled?(browser, element, how, what, desc = '')
        #TODO: handle identification of element with value as well as other attribute. see exists?
        msg = build_message("#{element.to_s.titlecase} by #{how}=>'#{what}' is disabled.", desc)
        case element
          when :textfield, :textarea, :text_area, :text_field
            rtrn = browser.text_field(how, what).disabled? ||
                browser.text_field(how, what).readonly?
          when :select_list, :selectlist
            rtrn = browser.select_list(how, what).disabled?
          when :checkbox
            rtrn = browser.checkbox(how, what).disabled?
          when :radio
            rtrn = browser.radio(how, what).disabled?
          when :button
            rtrn = browser.button(how, what).disabled?
          else
            rtrn = browser.element(how, what).disabled?
        end
        if rtrn
          passed_to_log("#{msg}")
          true
        else
          failed_to_log("#{msg}")
        end
        rtrn
      rescue
        failed_to_log("#Unable to verify that #{msg}: '#{$!}'")
      end

      alias validate_not_enabled disabled?
      alias validate_disabled disabled?

      # Verify that a DOM element is visible.
      # @param (see #enabled?)
      # @return [Boolean] Returns true if the element is visible.
      def visible?(browser, element, how, what, desc = '')
        #TODO: handle identification of element with value as well as other attribute. see exists?
        msg  = build_message("#{element.to_s.titlecase} #{how}=>'#{what}' is visible.", desc)
        rtrn = false
        case how
          when :index
            target = get_element(browser, element, how, what)
            if target.visible?
              rtrn = true
            end
          else
            if browser.element(how, what).visible?
              rtrn = true
            end
        end
        if rtrn
          passed_to_log("#{msg}")
        else
          failed_to_log("#{msg}")
        end
        rtrn
      rescue
        failed_to_log("Unable to verify that #{msg}': '#{$!}'")
      end

      alias validate_visible visible?

      # Verify that a DOM element is not visible.
      # @param (see #enabled?)
      # @return [Boolean] Returns true if the element is not visible.
      def not_visible?(browser, element, how, what, desc = '')
        #TODO: handle identification of element with value as well as other attribute.  see exists?
        msg  = build_message("#{element.to_s.titlecase} #{how}=>'#{what}' is not visible.", desc)
        rtrn = false
        case how
          when :index
            target = get_element(browser, element, how, what)
            if not target.visible?
              rtrn = true
            end
          else
            if not browser.element(how, what).visible?
              rtrn = true
            end
        end
        if rtrn
          passed_to_log("#{msg}")
        else
          failed_to_log("#{msg}")
        end
        rtrn
      rescue
        failed_to_log("Unable to verify that #{msg}': '#{$!}' #{desc}")
      end

      alias validate_not_visible not_visible?

      # Verify that a checkbox is checked.
      # @param [Watir::Browser] browser A reference to the browser window or container element to be tested.
      # @param [Symbol] how The element attribute used to identify the specific element.
      #   Valid values depend on the kind of element.
      #   Common values: :text, :id, :title, :name, :class, :href (:link only)
      # @param [String, Regexp] what A string or a regular expression to be found in the *how* attribute that uniquely identifies the element.
      # @param [String] desc Contains a message or description intended to appear in the log and/or report output
      # @return [Boolean] Returns true if the checkbox is checked.
      def checked?(browser, how, what, desc = '')
        #TODO: handle identification of element with value as well as other attribute.  see exists?
        msg = build_message("Checkbox #{how}=>#{what} is checked.", desc)
        if browser.checkbox(how, what).checked?
          passed_to_log(msg)
          true
        else
          failed_to_log(msg)
        end
      rescue
        failed_to_log("Unable to verify that #{msg}: '#{$!}'")
      end

      alias checkbox_checked? checked?
      alias checkbox_set? checked?

      # Verify that a checkbox is not checked.
      # @param (see #checked?)
      # @return [Boolean] Returns true if the checkbox is not checked.
      def not_checked?(browser, how, what, desc = '')
        #TODO: handle identification of element with value as well as other attribute. see exists?
        msg = build_message("Checkbox #{how}=>#{what} is not checked.", desc)
        if not browser.checkbox(how, what).checked?
          passed_to_log(msg)
          true
        else
          failed_to_log(msg)
        end
      rescue
        failed_to_log("Unable to verify that #{msg}: '#{$!}'")
      end

      alias checkbox_checked? checked?
      alias checkbox_set? checked?

      # Verify that a DOM element exists on the page.
      # @param [Watir::Browser] browser A reference to the browser window or container element to be tested.
      # @param [Symbol] how The element attribute used to identify the specific element.
      #   Valid values depend on the kind of element.
      #   Common values: :text, :id, :title, :name, :class, :href (:link only)
      # @param [String, Regexp] what A string or a regular expression to be found in the *how* attribute that uniquely identifies the element.
      # @param [String, Regexp] value A string or a regular expression to be found in the value attribute of the element.
      # @param [String] desc Contains a message or description intended to appear in the log and/or report output
      # @return [Boolean] True if the element exists.
      def exists?(browser, element, how, what, value = nil, desc = '')
        msg2 = "and value=>'#{value}' " if value
        msg = build_message("#{element.to_s.titlecase} with #{how}=>'#{what}' ", msg2, 'exists.', desc)
        e   = get_element(browser, element, how, what, value)
        if e
          passed_to_log("#{msg}? #{desc}")
          true
        else
          failed_to_log("#{msg}? #{desc} [#{get_callers(1)}]")
        end
      rescue
        failed_to_log("Unable to verify that #{msg}. #{desc} '#{$!}' [#{get_callers(1)}]")
      end

      # Verify that a DOM element does not exist on the page.
      # @param (see #exists?)
      # @return [Boolean] True if the element does not exist.
      def does_not_exist?(browser, element, how, what, value = nil, desc = '')
        msg2 = "and value=>'#{value}' " if value
        msg = build_message("#{element.to_s.titlecase} with #{how}=>'#{what}' ", msg2, 'does not exist.', desc)
        if browser.element(how, what).exists?
          failed_to_log(msg)
        else
          passed_to_log(msg)
          true
        end
      rescue
        failed_to_log("Unable to verify that #{msg}': '#{$!}' #{desc}")
      end

      alias not_exist? does_not_exist?

      # Verify that a radio button is set.
      # @param (see #checked?)
      # @return [Boolean] Returns true if the radio button is set.
      def set?(browser, how, what, desc = '', no_fail = false)
        #TODO: handle identification of element with value as well as other attribute. see radio_with_value_set?
        msg = build_message("Radio #{how}=>#{what} is selected.", desc)
        if browser.radio(how, what).set?
          passed_to_log(msg)
          true
        else
          if no_fail
            passed_to_log("Radio #{how}=>#{what} is not selected.")
          else
            failed_to_log(msg)
          end
        end
      rescue
        failed_to_log("Unable to verify taht #{msg}: '#{$!}'")
      end

      alias radio_set? set?
      alias radio_checked? set?
      alias radio_selected? set?

      # Verify that a radio button is not set.
      # @param (see #checked?)
      # @return [Boolean] Returns true if the radio button is not set.
      def not_set?(browser, how, what, desc = '', no_fail = false)
        #TODO: handle identification of element with value as well as other attribute. see radio_with_value_set?
        msg = build_message("Radio #{how}=>#{what} is not selected.", desc)
        if not browser.radio(how, what).set?
          passed_to_log(msg)
          true
        else
          if no_fail
            passed_to_log("Radio #{how}=>#{what} is not selected.")
          else
            failed_to_log(msg)
          end
        end
      rescue
        failed_to_log("Unable to verify that #{msg}: '#{$!}'")
      end

      alias radio_not_set? not_set?
      alias radio_not_checked? not_set?
      alias radio_not_selected? not_set?

      # Verify that a radio button, identified by both the value (+what+) in attribute +how+
      # and the +value+ in its value attribute, is set.
      # @param [Watir::Browser] browser A reference to the browser window or container element to be tested.
      # @param [Symbol] how The element attribute used to identify the specific element.
      #   Valid values depend on the kind of element.
      #   Common values: :text, :id, :title, :name, :class, :href (:link only)
      # @param [String, Regexp] what A string or a regular expression to be found in the *how* attribute that uniquely identifies the element.
      # @param [String, Regexp] value A string or a regular expression to be found in the value attribute of the element.
      # @param [String] desc Contains a message or description intended to appear in the log and/or report output
      # @return [Boolean] Returns true if the radio button is set.
      def radio_with_value_set?(browser, how, what, value, desc = '', no_fail = false)
        msg2 = 'not' if no_fail
        msg = build_message("Radio #{how}=>#{what} :value=>#{value} is", msg2, 'selected.', desc)
        if browser.radio(how, what, value).set?
          passed_to_log(msg)
          true
        else
          if no_fail
            passed_to_log(msg)
          else
            failed_to_log(msg)
          end
        end
      rescue
        failed_to_log("Unable to verify that #{msg}: '#{$!}'")
      end

      alias radio_set_with_value? radio_with_value_set?

      def select_list_includes?(browser, how, what, option, desc = '')
        msg = "Select list #{how}=>#{what} includes option '#{option}'."
        msg << " #{desc}" if desc.length > 0
        select_list = browser.select_list(how, what)
        options     = select_list.options
        if option
          if options.include?(option)
            passed_to_log(msg)
            true
          else
            failed_to_log(msg)
            nil
          end
        end
      rescue
        failed_to_log("Unable to verify #{msg}. '#{$!}'")
      end

      alias validate_select_list_contains select_list_includes?
      alias select_list_contains? select_list_includes?

      def select_list_does_not_include?(browser, how, what, option, desc = '')
        msg = "Select list #{how}=>#{what} does not include option '#{option}'."
        msg << " #{desc}" if desc.length > 0
        select_list = browser.select_list(how, what)
        options     = select_list.options
        if option
          if not options.include?(option)
            passed_to_log(msg)
            true
          else
            failed_to_log(msg)
            nil
          end
        end
      rescue
        failed_to_log("Unable to verify #{msg}. '#{$!}'")
      end

      def string_equals?(actual, target, desc = '')
        msg = "Assert actual '#{actual}' equals expected '#{target}'. #{desc} "
        if actual == target
          passed_to_log("#{msg}")
          true
        else
          failed_to_log("#{msg}")
        end
      rescue
        failed_to_log("Unable to #{msg}. #{$!}")
      end

      alias validate_string_equal string_equals?
      alias validate_string_equals string_equals?
      alias text_equals string_equals?
      alias text_equals? string_equals?

      def string_does_not_equal?(strg, target, desc = '')
        msg = "String '#{strg}' does not equal '#{target}'."
        msg << " '#{desc}' " if desc.length > 0
        if strg == target
          failed_to_log("#{msg} (#{__LINE__})")
          true
        else
          passed_to_log("#{msg} (#{__LINE__})")
        end
      end

      alias validate_string_not_equal string_does_not_equal?
      alias validate_string_does_not_equal string_does_not_equal?

      def date_string_equals?(actual, expected, desc = '', fail_on_format = true)
        rtrn = false
        msg  = build_message("Actual date '#{actual}' equals expected date '#{expected}'.", desc)
        if actual == expected
          rtrn = true
        elsif DateTime.parse(actual).to_s == DateTime.parse(expected).to_s
          msg << " with different formatting. "
          if not fail_on_format
            rtrn = true
          end
        end
        msg << " #{desc}" if desc.length > 0
        if rtrn
          passed_to_log("#{msg}")
        else
          failed_to_log("#{msg}")
        end
        rtrn
      rescue
        failed_to_log("Unable to #{msg}. #{$!}")
      end

      # Verify that a DOM element is in read-only state.
      # @param (see #enabled?)
      # @return [Boolean] Returns true if the element is in read-only state.
      def read_only?(browser, element, how, what, value = nil, desc = '')
        msg = "#{element.to_s.titlecase} with #{how}=>'#{what}' "
        msg << "and value=>'#{value}' " if value
        msg << "read only"
        e = get_element(browser, element, how, what, value)
        if e
          if e.readonly?
            passed_to_log("#{msg}? #{desc}")
            true
          else
            failed_to_log("#{msg}? #{desc} [#{get_callers(1)}]")
          end
        end
      rescue
        failed_to_log("Unable to determine if #{msg}. #{desc} '#{$!}' [#{get_callers(1)}]")
      end

      # Verify that a DOM element is not in read-only state.
      # @param (see #enabled?)
      # @return [Boolean] Returns true if the element is not in read-only state.
      def not_read_only?(browser, element, how, what, value = nil, desc = '')
        msg = "#{element.to_s.titlecase} with #{how}=>'#{what}' "
        msg << "and value=>'#{value}' " if value
        msg << "is not read only"
        e = get_element(browser, element, how, what, value)
        if e
          if e.readonly?
            failed_to_log("#{msg}? #{desc} [#{get_callers(1)}]")
          else
            passed_to_log("#{msg}? #{desc}")
            true
          end
        end
      rescue
        failed_to_log("Unable to determine if #{msg}. #{desc} '#{$!}' [#{get_callers(1)}]")
      end

      # Verify that a DOM element is ready, i.e., both exists and is enabled.
      # @param (see #exists?)
      # @return [Boolean] Returns true if the element is ready.
      def ready?(browser, element, how, what, value = '', desc = '')
        msg2 = "and value=>'#{value}' " if value
        msg = build_message("#{element.to_s.titlecase} with #{how}=>'#{what}' ", msg2, 'exists and is enabled.', desc)
        e = get_element(browser, element, how, what, value)
        if e and e.enabled?
          passed_to_log(msg)
          true
        else
          failed_to_log(msg)
        end
      rescue
        failed_to_log("Unable to determine if #{msg}. '#{$!}' [#{get_callers(1)}]")
      end

      def textfield_equals?(browser, how, what, expected, desc = '')
        msg    = build_message("Expected value to equal '#{expected}' in textfield #{how}=>'#{what}'.", desc)
        actual = browser.text_field(how, what).value
        if actual.is_a?(Array)
          actual = actual[0].to_s
        end
        if actual == expected
          passed_to_log(msg)
          true
        else
          act_s = actual.strip
          exp_s = expected.strip
          if act_s == exp_s
            passed_to_log("#{msg} (stripped)")
            true
          else
            debug_to_report(
                "#{__method__} (spaces underscored):\n "+
                    "expected:[#{expected.gsub(' ', '_')}] (#{expected.length})\n "+
                    "actual:[#{actual.gsub(' ', '_')}] (#{actual.length}) (spaces underscored)"
            )
            failed_to_log("#{msg}. Found: '#{actual}'")
          end
        end
      rescue
        failed_to_log("Unable to verify that #{msg}: '#{$!}")
      end

      alias validate_textfield_value textfield_equals?
      alias text_field_equals? textfield_equals?

      def textfield_contains?(browser, how, what, value, desc = '')
        msg = build_message("Text field #{how}=>#{what} contains '#{value}'.", desc)
        contents = browser.text_field(how, what).value
        if contents =~ /#{value}/
          passed_to_log(msg)
          true
        else
          failed_to_log("#{msg} Contents: '#{contents}'")
        end
      rescue
        failed_to_log("Unable to verify that #{msg}  '#{$!}'")
      end

      def textfield_empty?(browser, how, what, desc = '')
        msg = "Text field #{how}=>#{what} is empty."
        msg << desc if desc.length > 0
        contents = browser.text_field(how, what).value
        if contents.to_s.length == 0
          passed_to_log(msg)
          true
        else
          failed_to_log("#{msg} Contents: '#{contents}'")
        end
      rescue
        failed_to_log("Unable to verify that #{msg}  '#{$!}'")
      end

      alias validate_textfield_empty textfield_empty?
      alias text_field_empty? textfield_empty?

      def validate_textfield_dollar_value(browser, how, what, expected, with_cents = true, desc = '')
        desc << " Dollar formatting"
        if with_cents
          expected << '.00' if not expected =~ /\.00$/
          desc << ' without cents.'
        else
          expected.gsub!(/\.00$/, '')
          desc << ' with cents.'
        end
        textfield_equals?(browser, how, what, expected, desc)
      end

      def validate_url(browser, url, message = '')
        if browser.url.to_s.match(url)
          passed_to_log('Found "'+url.to_s+'" ' + message)
          true
        else
          failed_to_log('Did not find "'+url.to_s+'" ' + message + " (#{__LINE__})")
        end
      rescue
        failed_to_log("Unable to validate that current url is '#{url}': '#{$!}'. (#{__LINE__})")
      end

      # @!endgroup Core

      # @!group AutoIT

      def window_exists?(title)
        title = translate_popup_title(title)
        if @ai.WinExists(title) == 1
          passed_to_log("Window title:'#{title}' exists")
          true
        else
          failed_to_log("Window title:'#{title}' does not exist")
        end
      end

      alias window_exists window_exists?

      def window_does_not_exist?(title)
        title = translate_popup_title(title)
        if @ai.WinExists(title) == 1
          failed_to_log("Window title:'#{title}' exists")
        else
          passed_to_log("Window title:'#{title}' does not exist")
          true
        end
      end

      alias window_no_exists window_does_not_exist?

      # @!endgroup AutoIT

      # @!group Legacy

      # Verify that link identified by :text exists.
      # @param [Watir::Browser] browser A reference to the browser window or container element to be tested.
      # @param [String, Regexp] what A string or a regular expression to be found in the *how* attribute that uniquely identifies the element.
      # @param [String] desc Contains a message or description intended to appear in the log and/or report output
      # @return (see #exists?)
      def validate_link_exist(browser, what, desc = '')
        exists?(browser, :link, :text, what, nil, desc)
      end

      # Verify that link identified by :text does not exist.
      # @param (see #validate_link_exist)
      # @return (see #does_not_exist?)
      def link_not_exist?(browser, what, desc = '')
        does_not_exist?(browser, :link, :text, what, nil, desc)
      end

      alias validate_link_not_exist link_not_exist?

      # Verify that div identified by :id is visible.
      # @param (see #validate_link_exist)
      # @return [Boolean] True if the element is visible.
      def validate_div_visible_by_id(browser, what)
        visible?(browser, :div, :id, what)
      end

      # Verify that div identified by :id is not visible.
      # @param (see #validate_link_exist)
      # @return [Boolean] True if the element is not visible.
      def validate_div_not_visible_by_id(browser, what, desc = '')
        not_visible?(browser, :div, :id, what, desc)
      end

      # Verify that div identified by :text is enabled.
      # @param (see #validate_link_exist)
      # @return [Boolean] True if the element is enabled.
      def link_enabled?(browser, what, desc = '')
        enabled?(browser, :link, :text, what, desc)
      end

      alias validate_link_enabled link_enabled?

      # Verify that div identified by :text is disabled.
      # @param (see #validate_link_exist)
      # @return [Boolean] True if the element is disabled.
      def link_disabled?(browser, what, desc = '')
        disabled?(browser, :link, :text, what, desc)
      end

      alias validate_link_not_enabled link_disabled?

      # @!endgroup Legacy

      def popup_exists?(popup, message=nil)
        if not message
          message = "Popup: #{popup.title}"
        end
        if is_browser?(popup)
          passed_to_log("#{message}: found.")
          debug_to_log("\n"+popup.text+"\n")
          true
        else
          failed_to_log("#{message}: not found." + " (#{__LINE__})")
        end
      rescue
        failed_to_log("Unable to validate existence of popup: '#{$!}'. (#{__LINE__})")
      end

      alias popup_exist popup_exists?
      alias popup_exists popup_exists?
      alias popup_exist? popup_exists?
      alias iepopup_exist popup_exists?
      alias iepopup_exist? popup_exists?
      alias iepopup_exists popup_exists?
      alias iepopup_exists? popup_exists?

      def validate_drag_drop(err, tol, exp, act)
        ary = [false, "failed, expected: #{exp}, actual: #{act}, err: #{err}"]
        if err == 0
          ary = [true, 'succeeded ']
        elsif err.abs <= tol
          ary = [true, "within tolerance (+-#{tol}px) "]
        end
        ary
      end

      #Validate select list contains text
      def validate_list_by_id(browser, what, option, desc = '', select_if_present = true)
        if select_list_includes?(browser, :id, what, option, desc)
          if select_if_present
            select_option(browser, :id, what, :text, option, desc, false)
          else
            passed_to_log(message)
            true
          end
        end
      end

      #Validate select list contains text
      def validate_list_by_name(browser, what, option, desc = '', select_if_present = true)
        if select_list_includes?(browser, :name, what, option, desc)
          if select_if_present
            select_option(browser, :name, what, :text, option, desc, false)
          else
            passed_to_log(message)
            true
          end
        end
      end

      def validate_text(browser, ptrn, desc = '', skip_fail = false, skip_sleep = false)
        cls = browser.class.to_s
        cls.gsub!('Watir::', '')
        cls.gsub!('IE', 'Browser')
        msg = build_message("#{cls} text contains  '#{ptrn}'.", desc)
        if ptrn.is_a?(Regexp)
          target = ptrn
        else
          target = Regexp.new(Regexp.escape(ptrn))
        end
        sleep_for(2) unless skip_sleep
        myText = browser.text
        if not myText.match(target)
          sleep_for(2) unless skip_sleep #TODO try a wait_until here?
          myText = browser.text
        end
        if myText.match(target)
          #if myText.match(ptrn)
          passed_to_log("#{msg}")
          true
        else
          if skip_fail
            debug_to_log("#{cls}  text does not contain the text: '#{ptrn}'.  #{desc}")
          else
            failed_to_log("#{msg}")
          end
          #debug_to_log("\n#{myText}")
        end
      rescue
        failed_to_log("Unable to verify that #{msg} '#{$!}'")
      end

      alias validate_link validate_text

      # @!group Core

      def text_in_element_equals?(browser, element, how, what, expected, desc = '')
        msg = "Expected exact text '#{expected}' in #{element} :#{how}=>#{what}."
        msg << " #{desc}" if desc.length > 0
        text = ''
        who  = browser.element(how, what)
        if who
          text = who.text
          if text == expected
            passed_to_log(msg)
            true
          else
            debug_to_log("exp: [#{expected.gsub(' ', '^')}]")
            debug_to_log("act: [#{text.gsub(' ', '^')}]")
            failed_to_log("#{msg} Found '#{text}'.")
          end
        end
      rescue
        failed_to_log("Unable to verify #{msg} '#{$!}'")
      end

      def element_contains_text?(browser, element, how, what, expected, desc = '')
        msg = "Element #{element} :{how}=>#{what} contains text '#{expected}'."
        msg << " #{desc}" if desc.length > 0
        who = browser.element(how, what)
        if who
          text = who.text
          if expected and expected.length > 0
            rgx = Regexp.new(Regexp.escape(expected))
            if text =~ rgx
              passed_to_log(msg)
              true
            else
              debug_to_log("exp: [#{expected.gsub(' ', '^')}]")
              debug_to_log("act: [#{text.gsub(' ', '^')}]")
              failed_to_log("#{msg} Found '#{text}'. #{desc}")
            end
          else
            if text.length > 0
              debug_to_log("exp: [#{expected.gsub(' ', '^')}]")
              debug_to_log("act: [#{text.gsub(' ', '^')}]")
              failed_to_log("#{msg} Found '#{text}'. #{desc}")
            else
              passed_to_log(msg)
              true
            end
          end
        end
      rescue
        failed_to_log("Unable to verify #{msg} '#{$!}'")
      end

      # @!endgroup Core

      # @!group Legacy

      def validate_list(browser, listId, text, message)
        validate_list_by_id(browser, listId, text, message)
      end

      #Validate select list does not contain text
      def validate_no_list(browser, id, text, desc = '')
        select_list_does_not_include?(browser, :id, id, text, desc)
      end

      def text_in_span_equals?(browser, how, what, expected, desc = '')
        text_in_element_equals?(browser, :span, how, what, expected, desc)
      end

      def span_contains_text?(browser, how, what, expected, desc = '')
        element_contains_text?(browser, :span, how, what, expected, desc)
      end

      alias valid_text_in_span span_contains_text?

      def validate_text_in_span_by_id(browser, id, strg = '', desc = '')
        element_contains_text?(browser, :span, :id, id, strg, desc)
      end

      def validate_select_list(browser, how, what, opt_type, list = nil, multiple = false, ignore = ['Select One'], limit = 5)
        mark_testlevel("#{__method__.to_s.titleize} (#{how}=>#{what})", 2)
        ok          = true
        select_list = browser.select_list(how, what)
        options     = select_list.options
        if list
          if options == list
            passed_to_log("Select list options list equals expected list #{list}")
          else
            debug_to_report("actual:\n#{nice_array(options, true)}")
            debug_to_report("expected:\n#{nice_array(list, true)}")
            failed_to_log("Select list options list #{nice_array(options, true)} "+
                              "does not equal expected list #{nice_array(list, true)}")
          end
        end

        #single selections
        cnt = 0
        options.each do |opt|
          if not ignore.include?(opt)
            cnt += 1
            ok  = select_option(select_list, opt_type, opt)
            break if not ok
            select_list.clear
            break if limit > 0 and cnt >= limit
          end
        end

        sleep_for(0.5)
        select_list.clear
        if ok and multiple
          if options.length > 2
            targets = list.slice(1, 2)
            select_option(select_list, opt_type, options[1])
            select_option(select_list, opt_type, options[2])
            selected = select_list.selected_options
            if selected == targets
              passed_to_log("Select list selected options equals expected #{targets}")
            else
              failed_to_log("Select list selected options #{selected} does not equal expected list #{targets.to_a}")
            end
          else
            debug_to_log("Too few options to test multiple selection (need 2 or more): '#{options}", __LINE__)
          end
        end
      rescue
        failed_to_log("Unable to validate select_list: '#{$!}'", __LINE__)
      end

      def validate_select_list_contents(browser, how, what, list)
        mark_testlevel("#{__method__.to_s.titleize} (#{what})", 2)
        select_list = browser.select_list(how, what)
        options     = select_list.options
        if list
          if options == list
            passed_to_log("Select list options list equals expected list #{list}")
            options
          else
            failed_to_log("Select list options list #{options} does not equal expected list #{list}")
            nil
          end
        end
      rescue
        failed_to_log("Unable to validate select_list contents: '#{$!}'", __LINE__)
      end

      def validate_selected_options(browser, how, what, list, desc = '')
        select_list = browser.select_list(how, what)
        selected    = select_list.selected_options.sort
        if list.is_a?(Array)
          if selected == list.sort
            passed_to_log("Expected options [#{list.sort}] are selected [#{selected}]. #{desc}")
          else
            failed_to_log("Selected options [#{selected}] do not match expected [#{list.sort}]. #{desc}")
            true
          end
        else
          if selected.length == 1
            if selected[0] =~ /#{list}/
              passed_to_log("Expected option [#{list}] was selected. #{desc}")
              true
            else
              failed_to_log("Expected option [#{list}] was not selected. Found [#{selected}]. #{desc}")
            end
          else
            if selected.include?(list)
              failed_to_log("Expected option [#{list}] was found among multiple selections [#{selected}]. #{desc}")
            else
              failed_to_log("Expected option [#{list}] was not found among multiple selections [#{selected}]. #{desc}")
            end
          end
        end

      rescue
        failed_to_log("Unable to validate selected option(s): '#{$!}' #{desc}", __LINE__)
      end

      alias validate_selections validate_selected_options
      alias validate_select_list_selections validate_selected_options

      def string_contains?(strg, target, desc = '')
        msg = "String '#{strg}' contains '#{target}'."
        msg << " '#{desc}' " if desc.length > 0
        if strg.match(target)
          passed_to_log("#{msg} (#{__LINE__})")
          true
        else
          failed_to_log("#{msg} (#{__LINE__})")
        end
      end

      alias validate_string string_contains?
      alias validate_string_contains string_contains?

      def string_does_not_contain?(strg, target, desc = '')
        msg = "String '#{strg}' does not contain '#{target}'."
        msg << " '#{desc}' " if desc.length > 0
        if strg.match(target)
          failed_to_log("#{msg} (#{__LINE__})")
          true
        else
          passed_to_log("#{msg} (#{__LINE__})")
        end
      end

      alias validate_string_not_contains string_does_not_contain?
      alias validate_string_not_contain string_does_not_contain?
      alias validate_string_does_not_contain string_does_not_contain?

      def validate_no_text(browser, ptrn, desc = '')
        cls = browser.class.to_s
        cls.gsub!('Watir::', '')
        cls.gsub!('IE', 'Browser')
        msg = "#{cls} does not contain text '#{ptrn}'."
        msg << " #{desc}" if desc.length > 0
        if ptrn.is_a?(Regexp)
          target = ptrn
        else
          target = Regexp.new(Regexp.escape(ptrn))
        end
        browser_text = browser.text
        if browser_text.match(target)
          failed_to_log("#{msg} [#{browser_text.match(target)[0]}]")
        else
          passed_to_log(msg)
          true
        end
      rescue
        failed_to_log("Unable to verify that #{msg}: '#{$!}'")
      end

      def textfield_does_not_equal?(browser, how, what, expected, desc = '')
        msg = "Text field #{how}=>#{what} does not equal '#{expected}'"
        msg << " #{desc}" if desc.length > 0
        if not browser.text_field(how, what).value == expected
          passed_to_log(msg)
          true
        else
          failed_to_log(msg)
        end
      rescue
        failed_to_log("Unable to validate that #{msg}: '#{$!}'")
      end

      alias validate_textfield_not_value textfield_does_not_equal?

      def validate_textfield_not_value_by_name(browser, name, value, desc = '')
        textfield_does_not_equal?(browser, :name, name, value, desc)
      end

      alias validate_textfield_no_value_by_name validate_textfield_not_value_by_name

      def validate_textfield_not_value_by_id(browser, id, value, desc = '')
        textfield_does_not_equal?(browser, :id, id, value, desc)
      end

      alias validate_textfield_no_value_by_id validate_textfield_not_value_by_id

      def validate_textfield_empty_by_name(browser, name, message = '')
        validate_textfield_empty(browser, :name, name, message)
      end

      def validate_textfield_empty_by_id(browser, id, message = '')
        validate_textfield_empty(browser, :id, id, message)
      end

      def validate_textfield_empty_by_title(browser, title, message = '')
        validate_textfield_empty(browser, :title, title, message)
      end

      def validate_textfield_value_by_name(browser, name, expected, desc = '')
        textfield_equals?(browser, :name, name, expected, desc)
      end

      def validate_textfield_value_by_id(browser, id, expected, desc = '')
        textfield_equals?(browser, :id, id, expected, desc)
      end

      def validate_textfield_visible_by_name(browser, strg, desc = '')
        visible?(browser, :text_field, :name, strg, desc)
      end

      alias visible_textfield_by_name validate_textfield_visible_by_name

      def validate_textfield_disabled_by_name(browser, strg, desc = '')
        disabled?(browser, :text_field, :name, strg, desc)
      end

      alias disabled_textfield_by_name validate_textfield_disabled_by_name

      def validate_textfield_enabled_by_name(browser, strg, desc = '')
        enabled?(browser, :text_field, :name, strg, desc)
      end

      alias enabled_textfield_by_name validate_textfield_enabled_by_name

      def validate_textfield_not_visible_by_name(browser, strg, desc = '')
        not_visible?(browser, :text_field, :name, strg, desc)
      end

      alias visible_no_textfield_by_name validate_textfield_not_visible_by_name

      def validate_radio_not_set(browser, what, desc = '')
        not_set?(browser, :id, what, desc)
      end

      alias validate_not_radioset validate_radio_not_set

      def radio_is_set?(browser, what, desc = '')
        set?(browser, :id, what, desc)
      end

      alias validate_radioset radio_is_set?
      alias validate_radio_set radio_is_set?

      def validate_radioset_by_name(browser, what, desc = '')
        set?(browser, :name, what, desc)
      end

      def checked_by_id?(browser, strg, desc = '')
        checked?(browser, :id, strg, desc)
      end

      alias validate_check checked_by_id?
      alias checkbox_is_checked? checked_by_id?

      def checkbox_is_enabled?(browser, strg, desc = '')
        enabled?(browser, :checkbox, :id, strg, desc)
      end

      alias validate_check_enabled checkbox_is_enabled?

      def checkbox_is_disabled?(browser, strg, desc = '')
        disabled?(browser, :checkbox, :id, strg, desc)
      end

      alias validate_check_disabled checkbox_is_disabled?

      def validate_check_by_class(browser, strg, desc)
        checked?(browser, :class, strg, desc)
      end

      def checkbox_not_checked?(browser, strg, desc)
        not_checked?(browser, :id, strg, desc)
      end

      alias validate_not_check checkbox_not_checked?

      def validate_image(browser, source, desc = '', nofail = false)
        exists?(browser, :image, :src, desc)
      end

      # @!endgroup Legacy

      # @!group Deprecated
      # @deprecated
      def self.included(mod)
        # puts "RegressionSupport::Validations extended by #{mod}"
      end

      # @deprecated Use #message_to_log
      def validate_message(browser, message)
        message_to_log(message)
      end

      # @!endgroup Deprecated

    end
  end
end

