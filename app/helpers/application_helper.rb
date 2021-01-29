module ApplicationHelper
  def colsort(column, title)
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, request.query_parameters.merge({ sort: column, direction: direction })
  end

  def active?(link_path)
    if current_page?(link_path)
      'navactive'
    else
      ''
    end
  end
end
