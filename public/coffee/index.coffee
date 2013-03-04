$ ->
  $("#survey_form").submit (e) ->
    e.preventDefault()
    answers = []
    $(".survey").each (i, el) ->
      answers.push $(el).find("input:checked").val() or null
    where  = $("#survey_form").attr("action")
    
    $.post where, {answers: answers}, (result) ->
      if result?.errors is null
        $("#survey_errors").html("survey submited successfully").attr("class", "success").fadeIn()
      else if result?.errors?
        $("#survey_errors").html(result.errors.join("<br>")).attr("class", "error").fadeIn()
      else
        $("#survey_errors").html("something bad happened").attr("class", "error").fadeIn()

  $(".delete_survey").click (e) ->
    e.preventDefault()
    if confirm("are you sure about that?")
      id = $(this).attr("id")
      $.post "/delete/survey", {id}, (res) =>
        if res.okay
          $(this).parent().fadeOut ->
            $(this).remove()

  $(".option").click (e) ->
    e.preventDefault()
    $(this).find("input:radio").prop("checked", true)

  $("#view_result").click (e) ->
    e.preventDefault()

  $(".survey_list").hover (e) ->
    $(this).toggleClass("survey_hovered")