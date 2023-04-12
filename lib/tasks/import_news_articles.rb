require 'csv'

namespace :import do
  desc "Import rows of csv file and create resources in database"
  task news_articles: :environment do
    csv_filepath = find_filepath('data', 'news_articles.csv')

    begin
      csv = read_csv_file(csv_filepath)
    rescue Errno::ENOENT, Errno::EACCES
      puts 'An error was raised when opening/reading the file'
    end

    csv.each do |row|
      date_count_hash = date_and_counts_hash(row['like_counts_per_date'])
      article = find_or_create_article_record_from_row_data(row, date_count_hash)
      # create associated like resources
      date_count_hash.each do |date, count|
        like = article.likes.find_or_create_by(date: date)
        like.update_attribute(:count, count.to_i)
      end
    end
  end

  def find_filepath(directory, filename)
    csv_filepath = Rails.root.join(directory, filename)
  end

  def find_or_create_article_record_from_row_data(r_data, hash)
    html_content = find_article_html_file(r_data['title'])

    total_count = sum_like_counts(hash)
    r_data = add_values_to_row_data(r_data, html_content, total_count)

    article_params = r_data.to_hash.slice('title','publication_date','category','author', 'body', 'total_like_count', 'slug')

    Article.find_or_create_by(article_params)
  end

  def add_values_to_row_data(row_data, html_content, total_count)
    row_data['body'] = html_content
    row_data['slug'] = row_data['title'].parameterize
    row_data['total_like_count'] = total_count
    return row_data
  end

  def date_and_counts_hash(dates_with_count_string)
    dates_with_count_string.split('|').map{|d| d.split(':')}.to_h
  end

  def find_article_html_file(title)
    html_filename = title.downcase.gsub(/[.:'%]/, '').gsub(/[^\w]/,'_') + '.html'
    html_filepath = find_filepath('data', html_filename)

    begin
      html_file = read_html_file(html_filepath)
    rescue Errno::ENOENT
      puts 'An error was raised'
    end
  end

  def read_csv_file(file)
    csv_file = file.read
    CSV.parse(csv_file, :headers=>true)
  end

  def read_html_file(file_path)
    File.read(file_path, encoding: "UTF-8")
  end

  def sum_like_counts(hash)
    hash.values.sum(&:to_i)
  end

end
