## result templates 
template = (type, el, color) ->

  if type is "common"
    return  "<div class='result'>" +
              "<div class='result-question'>" +
                "<span class='q'>#{el.q}</span>" + 
                "<span class='count'>#{el.count} votes</span>" + 
              "</div>" +
              "<div class='result-box'>" +
                "<div class='inside-result' style='width:#{340*(el.percent/100)}px; background: #{color}'> </div>" +
              "</div>" +
            "</div>"






$ ->
  questions = $(".questions").clone()
  
  #set up percent slider
  if $(".percent_input").length > 0
    $(".percent_input").simpleSlider()

  ## survey submited
  $("#survey_form").submit (e) ->
    e.preventDefault()
    ## if user views results disable click
    if $("#view_result").is(".result_clicked")
      return false

    answers = []
    $(".survey").each (i, el) ->
      type = $(el).data("type")
      ## get answer for each type of survey

      if type is "list_radio" or type is "yes_or_no"
        answers.push $(el).find("input:checked").val() or null

      if type is "list_dropdown"
        answers.push $(el).find("select option:selected").val() or null

      if type is "5_point" or type is "5_star"
        answers.push $(el).find("input:checked").val() or null

      if type is "text_long"
        answers.push $(this).find(".text_long textarea").val()

      if type is "text_short"
        answers.push $(this).find(".text_short input").val()

      if type is "percent"
        value = $(this).find(".percent_value").text()
        final_value = null

        if value <= 25 
          final_value = 0
        else if value <= 50
          final_value = 1
        else if value <= 75
          final_value = 2
        else if value <= 100
          final_value = 3

        answers.push final_value


    where  = $("#survey_form").attr("action")
    $.post where, {answers: answers}, (result) ->
      if result?.errors is null
        $("#survey_errors").html("survey submited successfully").attr("class", "success").fadeIn()
      else if result?.errors?
        $("#survey_errors").html(result.errors.join("<br>")).attr("class", "error").fadeIn()
      else
        $("#survey_errors").html("something bad happened").attr("class", "error").fadeIn()



  ## delete survey
  $(".delete_survey").click (e) ->
    e.preventDefault()
    if confirm("are you sure about that?")
      id = $(this).attr("id")
      $.post "/delete/survey", {id}, (res) =>
        if res.okay
          $(this).parent().fadeOut ->
            $(this).remove()



  ## make option clickable
  $(".questions").on "click", ".option", (e) ->
    e.preventDefault()
    $(this).find("input:radio").prop("checked", true)

  $(".survey_list").hover (e) ->
    $(this).toggleClass("survey_hovered")




  ## view survey results
  $("#view_result").click (e) ->
    e.preventDefault()

    if $(this).is(".result_clicked")
      $(".questions").each (i, q) -> $(q).html($(questions[i]).html())
      $("#view_result").text("Results").toggleClass("result_clicked")
      
      ## set up percent slider
      if $(".percent_input").length > 0
        $(".percent_input").simpleSlider()
        $(".percent").on  "change", ".percent_input", (data) ->
          value = Math.round(data.value*100)
          $(this).next().text(value)
    
    else
      where = $("#survey_form").attr("action") + "/results"
      $("#view_result").text("Questions").toggleClass("result_clicked")

      $.get where, (data) ->
        if not data.error?
          data  = data.result
          red   = "rgb(235, 157, 157)"
          green = "rgb(194, 230, 147)"

          $(".survey").each (i, survey) ->
            max = Math.max.apply( Math, data[i].map((x)-> x.percent) )

            $(survey).find(".questions").children().remove()
            data[i].forEach (el) ->
              color = if el.percent is max then red else green
              result_box = template("common", el, color)              
              $(survey).find(".questions").append(result_box)


  ## if user has already submited show results
  if $("#in_survey").data("exists") is true
    $("#view_result").trigger("click")
  


  ## point 5 survey type clicked
  $(".questions").on "click", ".point-5 .point-in", (e) ->
    $(this).closest(".point-out").prev().trigger("click")
    $(this).closest(".questions").find(".point-5 .point-in").not(this).removeClass("point-active")
    $(this).addClass("point-active");

  $(".questions").on "click", ".star-5 .point-in", (e) ->
    $(this).closest(".point-out").prev().trigger("click")
    $(this).closest(".questions").find(".star-5 .point-in").not(this).removeClass("star-active")
    $(this).addClass("star-active");


  ## percent changed in percent slider
  $(".percent").on  "change", ".percent_input", (data) ->
    value = Math.round(data.value*100)
    $(this).next().text(value)


