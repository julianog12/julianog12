class Diff < ActiveRecord::Base
  has_no_table

  column :before, :string
  column :after, :string


  def diff_content
    diff_info = Diffy::Diff.new(diff_before, diff_after, :diff => "-U 3", :include_plus_and_minus_in_html => true, :include_diff_info => true)
    diff_info.to_s(:html)
  end

  def before
    @before || ""
  end

  def after
    @after || ""
  end

  private

  def diff_before
    "#{self.attributes['before'].chomp}#{new_line}"
  end

  def diff_after
    "#{self.attributes['after'].chomp}#{new_line}"
  end

  def new_line
    self.attributes["before"].scan(/\r\n|\n|\n/)[0] || self.attributes["after"].scan(/\r\n|\n|\n/)[0] || ""
  end

end
