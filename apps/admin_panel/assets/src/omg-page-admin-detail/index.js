import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styled, { withTheme } from 'styled-components'
import { withRouter } from 'react-router-dom'
import AdminProvider from '../omg-admins/adminProvider'
import { compose } from 'recompose'
import Section, { DetailGroup } from '../omg-page-detail-layout/DetailSection'
import TopBar from '../omg-page-detail-layout/TopBarDetail'
import DetailLayout from '../omg-page-detail-layout/DetailLayout'
import moment from 'moment'
import Copy from '../omg-copy'
const UserDetailContainer = styled.div`
  padding-bottom: 20px;
  b {
    width: 150px;
    display: inline-block;
  }
`
const ContentDetailContainer = styled.div`
  margin-top: 40px;
  display: flex;
`
const DetailContainer = styled.div`
  flex: 1 1 50%;
  :first-child {
    margin-right: 20px;
  }
`
const ContentContainer = styled.div`
  display: inline-block;
  width: 100%;
`
const enhance = compose(
  withTheme,
  withRouter
)
class TokenDetailPage extends Component {
  static propTypes = {
    match: PropTypes.object
  }
  renderTopBar = admin => {
    return <TopBar title={admin.id} breadcrumbItems={['Admin', admin.id]} buttons={[]} />
  }
  renderDetail = admin => {
    return (
      <Section title='DETAILS'>
        <DetailGroup>
          <b>Id:</b> <span>{admin.id}</span> <Copy data={admin.id} />
        </DetailGroup>
        <DetailGroup>
          <b>Email:</b> <span>{admin.email || '-'}</span>
        </DetailGroup>
        <DetailGroup>
          <b>Created Date:</b> <span>{moment(admin.created_at).format('DD/MM/YYYY hh:mm:ss')}</span>
        </DetailGroup>
        <DetailGroup>
          <b>Last Update:</b> <span>{moment(admin.updated_at).format('DD/MM/YYYY hh:mm:ss')}</span>
        </DetailGroup>
      </Section>
    )
  }
  renderUserDetailContainer = admin => {
    return (
      <DetailLayout backPath={'/users'}>
        <ContentContainer>
          {this.renderTopBar(admin)}
          <ContentDetailContainer>
            <DetailContainer>{this.renderDetail(admin)}</DetailContainer>
          </ContentDetailContainer>
        </ContentContainer>
      </DetailLayout>
    )
  }

  renderUserDetailPage = ({ admin }) => {
    return (
      <UserDetailContainer>
        {admin ? this.renderUserDetailContainer(admin) : null}
      </UserDetailContainer>
    )
  }
  render () {
    return (
      <AdminProvider
        render={this.renderUserDetailPage}
        adminId={this.props.match.params.adminId}
        {...this.state}
        {...this.props}
      />
    )
  }
}

export default enhance(TokenDetailPage)
