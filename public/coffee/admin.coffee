$ ->
  $('#add_survey_form #type').data('pre', $(this).val());
  
  $("#login_form").submit (e) ->
    e.preventDefault()
    user     = $(this).find("input[name=user]").val()
    password = $(this).find("input[name=password]").val()

    $.post "/admin", {user, password}, (res) ->
      if res.okay
        window.location.replace("/admin")
      else
        $("#login_errors").html(res.errors.join("<br>")).attr("class", "error").fadeIn()

  ## add survey clicked
  $("#add_survey_link").click (e) ->
    e.preventDefault()
    $("#add_survey").toggle()

  ## set previous type
  $("#add_survey_form #type").focus -> previos_type = $(this).val() 

  ## type changed
  $("#add_survey_form #type").change ->
    previos_type = $(this).data("pre")
    type = $(this).val()
    
    $("#" + previos_type).hide()
    $("#" + type).show()
    $(this).data("pre", type)

  ## add inputs to radio list
  $("#add_list_radio").click (e) ->
    e.preventDefault()
    val = $(this).val()
    how_many = $("#list_radio_options").children().length/2

    if how_many < 6
      $("#list_radio_options").append($("<input name='option#{how_many+1}'></input><br>"))
  
  ## reset survey clicked
  $("#add_survey_form input:reset").click ->
    $("#list_radio #list_radio_options").children().remove()

  ## add survey submited 
  $("#add_survey_form").submit (e) ->
    e.preventDefault()
    obj = {}
    obj.name     = $(this).find("#name").val()
    obj.question = $(this).find("#question").val()
    obj.type     = $(this).find("#type").val()
    
    if obj.type is "list_radio"
      obj.option_count = $(this).find("#list_radio_options").children().length/2
      if obj.option_count > 0
        for i in [1..obj.option_count]
          obj["option" + i] = $("#list_radio_options input[name=option#{i}]").val()

    $.post "/create/survey" , obj, (r) ->
      if r.okay
        $("#add_survey_errors").html("survey added succesfully").attr("class", "success").fadeIn()
      else if r.errors?.length > 0
        $("#add_survey_errors").html(r.errors.join("<br>")).attr("class", "error").fadeIn()




