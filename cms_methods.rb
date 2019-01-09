SUPPORTED_EXTENTIONS = ['txt', 'md', 'png', 'jpg']

def render_markdown(file)
  headers["Content-Type"] = "text/html;charset=utf-8"
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(file)
end

def render_png(file)
  headers["Content-Type"] = "image/png"
  file
end

def get_file_content(file_path)
  @file = File.read(file_path)
  if file_path =~ /.md/
    render_markdown(@file)
  elsif file_path =~ /.png/
    render_png(@file)
  elsif file_path =~ /.jpg/
    render_png(@file)
  else
    @file
  end
end

def data_path # get absolute path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def create_document(name, content = "")
  File.open(File.join(data_path, name), "w") do |file|
    file.write(content)
  end
end

def upload_file(url)
  filename = File.basename(url)
  destination = File.join(data_path, filename)
  FileUtils.cp(url, destination)
end

def valid_doc_name?(document_name)
  !(document_name.to_s.empty? || document_name.strip == '') &&
  extention_supported?(document_name)
end

def extention_supported?(filename)
  _, extention = File.basename(filename).split('.')
  SUPPORTED_EXTENTIONS.include?(extention)
end

def write_versioned_file(file)
  timestamp = Time.now.strftime("%Y%m%d%H%M%S")

  file_without_extention, extention = file.split('.')
  extention = ".#{extention}" if extention

  versioned_file = "#{file_without_extention}_#{timestamp}#{extention}"
  File.rename(File.join(data_path,file),
              File.join(data_path,versioned_file))
end

def block_not_signed_in_users
  if session[:signed_in] == false
    session[:message] = "You must be signed in to do that."
    redirect '/'
  end
end

def user_credentials_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
end

def load_user_credentials
  credentials_path = user_credentials_path
  YAML.load_file(credentials_path)
end

def valid_user_name?(username)
  !(username.to_s.empty? || username.strip == '')
end

def valid_user_credentials?(username, password_attempt)
  user_credentials = load_user_credentials
  stored_password = user_credentials[username]

  if user_credentials.has_key?(username)
    bcrypt_password = BCrypt::Password.new(stored_password)
    bcrypt_password == password_attempt
  else
    false
  end
end

def add_user(username, password)
  bcrypt_password = BCrypt::Password.create(password).to_s
  new_user = "\n#{username}: #{bcrypt_password}"

  File.write(user_credentials_path, new_user, mode: 'a')
end
