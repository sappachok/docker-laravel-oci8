<?php

namespace App\Admin\Controllers;

use App\Models\Students;
use Encore\Admin\Controllers\AdminController;
use Encore\Admin\Form;
use Encore\Admin\Grid;
use Encore\Admin\Show;

class StudentsController extends AdminController
{
    /**
     * Title for current resource.
     *
     * @var string
     */
    protected $title = 'Students';

    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        $grid = new Grid(new Students());

        $grid->column('id', __('Id'));
        $grid->column('student_code', __('Student code'));
        $grid->column('first_name', __('First name'));
        $grid->column('last_name', __('Last name'));
        $grid->column('address', __('Address'));
        $grid->column('email', __('Email'));
        $grid->column('created_at', __('Created at'));
        $grid->column('updated_at', __('Updated at'));

        return $grid;
    }

    /**
     * Make a show builder.
     *
     * @param mixed $id
     * @return Show
     */
    protected function detail($id)
    {
        $show = new Show(Students::findOrFail($id));

        $show->field('id', __('Id'));
        $show->field('student_code', __('Student code'));
        $show->field('first_name', __('First name'));
        $show->field('last_name', __('Last name'));
        $show->field('address', __('Address'));
        $show->field('email', __('Email'));
        $show->field('created_at', __('Created at'));
        $show->field('updated_at', __('Updated at'));

        return $show;
    }

    /**
     * Make a form builder.
     *
     * @return Form
     */
    protected function form()
    {
        $form = new Form(new Students());

        $form->text('student_code', __('Student code'));
        $form->text('first_name', __('First name'));
        $form->text('last_name', __('Last name'));
        $form->textarea('address', __('Address'));
        $form->email('email', __('Email'));

        return $form;
    }
}
