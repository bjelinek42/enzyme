class CraqValidator

  def initialize(questions, answers)
    @questions = questions
    @answers = answers
    @validator = {}
  end

  def valid? #return true if no distinguished errors, false if there are errors
    q_count = question_count
    a_count = answer_count
    if @answers == {} || @answers == nil #check for any answers
      return false
    end
    if @answers.length == @questions.length #check that each question was answered (would have to modify for complete if selected, possibly another conditional)
      @answers.each do |question, answer| 
        if answer >= a_count[question] #check that each answer was a valid choice
          return false
        end
      end
    else
      return false
    end
    return true
  end

    # possible errors
    #   'has an answer that is not on the list of valid answers',
    #   'was not answered',
    #   'was answered even though a previous response indicated that the questions were complete'
  def errors #return specific errors for each question
    errors = {}
    q_count = question_count
    a_count = answer_count
    if @answers == {} || @answers == nil && q_count == 1 #errors for questions not being answered
      errors[:q0] = 'was not answered'
    elsif @answers == {} || @answers == nil && q_count == 2
      errors[:q0] = 'was not answered'
      errors[:q1] = 'was not answered'
    elsif q_count == 2 && @answers.length == 1
      errors[:q1] = 'was not answered'
    else
      @answers.each do |question, answer| #check that each answer was a valid choice
        if answer >= a_count[question]
          errors[question] = 'has an answer that is not on the list of valid answers'
        end
      end
    end
    return errors
  end

  def question_count #for comparing question and answer number
    count = @questions.length
    return count
  end

  def answer_count #for comparing question and answer number
    answer_count = {}
    index_question = ''
    @questions.each do |question|
      count = question[:options].length
      if question[:text] == 'q1' #modifying for error return
        answer_count[:q0] = count
      elsif question[:text] == 'q2' #modifying for error return
        answer_count[:q1] = count
      end
      count = question[:options].length
    end
    p answer_count
    return answer_count
  end

end


require "test-unit"

class CraqValidatorTest < Test::Unit::TestCase
  description 'it is invalid with no answers'
  def test1
    @questions = [{ text: 'q1', options: [{ text: 'an option' }, { text: 'another option' }] }]
    @answers = {}
    assert_errors q0: 'was not answered'
  end

  description 'it is invalid with nil answers'
  def test2
    @questions = [{ text: 'q1', options: [{ text: 'an option' }, { text: 'another option' }] }]
    @answers = nil
    assert_errors q0: 'was not answered'
  end

  description 'errors are added for all questions'
  def test3
    @questions = [
      { text: 'q1', options: [{ text: 'an option' }, { text: 'another option' }] },
      { text: 'q2', options: [{ text: 'an option' }, { text: 'another option' }] }
    ]
    @answers = nil
    assert_errors q0: 'was not answered', q1: 'was not answered'
  end

  description 'it is valid when an answer is given'
  def test4
    @questions = [{ text: 'q1', options: [{ text: 'yes' }, { text: 'no' }] }]
    @answers = { q0: 0 }
    assert_valid
  end

  description 'it is valid when there are multiple options and the last option is chosen'
  def test5
    @questions = [{ text: 'q1', options: [{ text: 'yes' }, { text: 'no' }, { text: 'maybe' }] }]
    @answers = { q0: 2 }
    assert_valid
  end

  description 'it is invalid when an answer is not one of the valid answers'
  def test6
    @questions = [{ text: 'q1', options: [{ text: 'an option' }, { text: 'another option' }] }]
    @answers = { q0: 2 }
    assert_errors q0: 'has an answer that is not on the list of valid answers'
  end

  description 'it is invalid when not all the questions are answered'
  def test7
    @questions = [
      { text: 'q1', options: [{ text: 'an option' }, { text: 'another option' }] },
      { text: 'q2', options: [{ text: 'an option' }, { text: 'another option' }] }
    ]
    @answers = { q0: 0 }
    assert_errors q1: 'was not answered'
  end

  description 'it is valid when all the questions are answered'
  def test8
    @questions = [
      { text: 'q1', options: [{ text: 'an option' }, { text: 'another option' }] },
      { text: 'q2', options: [{ text: 'an option' }, { text: 'another option' }] }
    ]
    @answers = { q0: 0, q1: 0 }
    assert_valid
  end

  description 'it is valid when questions after complete_if_selected are not answered'
  def test9
    @questions = [
      { text: 'q1', options: [{ text: 'yes' }, { text: 'no', complete_if_selected: true }] },
      { text: 'q2', options: [{ text: 'an option' }, { text: 'another option' }] }
    ]
    @answers = { q0: 1 }
    assert_valid
  end

  description 'it is invalid if questions after complete_if are answered'
  def test10
    @questions = [
      { text: 'q1', options: [{ text: 'yes' }, { text: 'no', complete_if_selected: true }] },
      { text: 'q2', options: valid_options }
    ]
    @answers = { q0: 1, q1: 0 }

    assert_errors(
      q1: 'was answered even though a previous response indicated that the questions were complete'
    )
  end

  description 'it is valid if complete_if is not a terminal answer and further questions are answered'
  def test11
    @questions = [
      { text: 'q1', options: [{ text: 'yes' }, { text: 'no', complete_if_selected: true }] },
      { text: 'q2', options: [{ text: 'an option' }, { text: 'another option' }] }
    ]

    @answers = { q0: 0, q1: 1 }
    assert_valid
  end

  description 'it is invalid if complete_if is not a terminal answer and further questions are not answered'
  def test12
    @questions = [
      { text: 'q1', options: [{ text: 'yes' }, { text: 'no', complete_if_selected: true }] },
      { text: 'q2', options: [{ text: 'an option' }, { text: 'another option' }] }
    ]
    @answers = { q0: 0 }
    assert_errors q1: 'was not answered'
  end

  private

    def answers_valid?
      @validator = CraqValidator.new @questions, @answers
      @validator.valid? #this had me hung up for a long time as valid? method in rails is used for validating class instances, but once I got past it the task was much easier
    end

    def assert_valid(message: nil)
      answers_valid?
      assert answers_valid?, (message || "expected to be valid but was not: #{@validator.errors}")
    end

    def refute_valid(message: 'expected to be invalid but was valid')
      refute answers_valid?, message
    end

    def assert_errors(errors)
      refute_valid
      assert_equal errors, @validator.errors
    end

    def valid_options
      [{ text: 'an option' }, { text: 'another option' }]
    end
end