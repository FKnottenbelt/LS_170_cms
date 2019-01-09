def same_document_content?(doc1, doc2)
  doc1_content = get_file_content(File.join(data_path, doc1))
  doc2_content = get_file_content(File.join(data_path, doc2))
  doc1_content == doc2_content
end

def delete_user(username)
  user_credentials = load_user_credentials
  user_credentials.delete(username)
  File.write(user_credentials_path, user_credentials.to_yaml, mode: 'w')
end

def user_exists?(username)
  user_credentials = load_user_credentials
  user_credentials.has_key?(username)
end