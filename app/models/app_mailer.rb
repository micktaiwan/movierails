class AppMailer < ActionMailer::Base
  
  def alert(title, msg)
    @subject    = '[PTM] ' + title
    @body["msg"] = msg
    @recipients = 'faivrem@gmail.com'
    @from       = 'protask@protaskm.com'
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def lost_password(user,key)
    @subject    = '[PTM] password reset'
    @body["user"] = user
    @body["key"] = key
    @recipients = user.email
    @from       = 'protask@protaskm.com'
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def registration_mail(user)
    @subject    = '[PTM] Welcome'
    @body["user"] = user
    @recipients = user.email
    @from       = 'protask@protaskm.com'
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def invite_users(i,p,from)
    @subject    = "[PTM] #{i.name} invited you on PTM"
    @body["i"] = i
    @body["p"] = p
    @body["from"] = from
    @recipients = i.email
    if from.email != ''
      @from       = from.email
    else
      @from       = 'protask@protaskm.com'
    end
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def invite_result(i,txt)
    @subject    = "[PTM] invitation #{txt}"
    @body["i"] = i
    @body["txt"] = txt
    @recipients = i.user.email
    @from       = 'protask@protaskm.com'
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def reminders(u,dates)
    @subject    = "[PTM] Reminders for #{Date.today}"
    @body["u"]  = u
    @body["dates"] = dates
    @recipients = u.email
    @from       = 'protask@protaskm.com'
    @sent_on    = Time.now
    @headers    = {}
  end
  
end

